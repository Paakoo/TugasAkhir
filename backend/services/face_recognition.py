import h5py
import numpy as np
from deepface import DeepFace
from retinaface import RetinaFace
from scipy.spatial.distance import cosine
from config.settings import Config
import cv2
import os
import time

def load_h5_embeddings():
    try:
        embeddings = {}
        with h5py.File(Config.EMBEDDINGS_PATH, 'r') as hf:
            for username in hf.keys():
                clean_username = username.replace('user_', '')
                embeddings[clean_username] = np.array(hf[username])
        return embeddings
    except Exception as e:
        print(f"Error loading embeddings: {e}")
        return {}

def compare_embeddings(embedding1, embedding2):
    return 1 - cosine(embedding1, embedding2)

def find_matching_face(new_embedding, stored_embeddings, threshold=0.75):
    max_similarity = -1
    matched_name = None
    
    for username, user_embeddings in stored_embeddings.items():
        if len(user_embeddings.shape) == 1:
            user_embeddings = np.array([user_embeddings])
            
        for stored_embedding in user_embeddings:
            similarity = compare_embeddings(new_embedding, stored_embedding)
            if similarity > max_similarity:
                max_similarity = similarity
                matched_name = username
    
    if max_similarity >= threshold:
        return matched_name, max_similarity
    return None, max_similarity

def save_h5_embeddings(embeddings):
    try:
        with h5py.File(Config.EMBEDDINGS_PATH, 'w') as hf:
            for username, embedding in embeddings.items():
                hf.create_dataset(username, data=embedding)
        return True
    except Exception as e:
        print(f"Error saving embeddings: {e}")
        return False

def update_dataset():
    start_time = time.time()
    try:
        existing_embeddings = load_h5_embeddings()
        current_folders = set([f for f in os.listdir(Config.BASE_FOLDER) if os.path.isdir(os.path.join(Config.BASE_FOLDER, f))])

        # Jika BASE_FOLDER kosong, tetap pertahankan existing_embeddings
        if not current_folders:
            if existing_embeddings:
                save_h5_embeddings(existing_embeddings)
            return {
                'status': 'success',
                'message': 'No new folders found, existing embeddings preserved',
                'data': {
                    'processed_users': [],
                    'skipped_users': [],
                    'removed_users': [],
                    'total_processed': 0,
                    'total_skipped': 0,
                    'total_removed': 0
                },
                'time_taken': f"{time.time() - start_time:.3f}s"
            }, 200

        existing_users = set(existing_embeddings.keys())
#        removed_folders = existing_users - current_folders
        new_folders = current_folders - existing_users

        processed_users = []
        skipped_users = []
        removed_users = []

        # Only remove embeddings if the folder is explicitly removed
 #       if removed_folders:
  #          for username in removed_folders:
   #             if username in existing_embeddings:
    #                del existing_embeddings[username]
     #               removed_users.append(username)

        # Process only new folders, retain existing embeddings
        for username in new_folders:
            user_path = os.path.join(Config.BASE_FOLDER, username)
            user_embeddings = []

            for img_name in os.listdir(user_path):
                if img_name.lower().endswith(('.png', '.jpg', '.jpeg')):
                    img_path = os.path.join(user_path, img_name)
                    try:
                        embedding_obj = DeepFace.represent(
                            img_path=img_path,
                            model_name=Config.FACE_RECOGNITION_MODEL,
                            detector_backend=Config.FACE_DETECTION_MODEL,
                            enforce_detection=True,
                            align=True
                        )
                        embedding_vector = np.array(embedding_obj[0]['embedding'])
                        user_embeddings.append(embedding_vector)
                    except Exception as e:
                        print(f"Error processing {img_path}: {e}")
                        continue

            if user_embeddings:
                existing_embeddings[username] = np.array(user_embeddings)
                processed_users.append(username)
            else:
                skipped_users.append(username)

        if removed_users or processed_users:
            save_h5_embeddings(existing_embeddings)

        return {
            'status': 'success',
            'message': 'Dataset updated successfully',
            'data': {
                'processed_users': processed_users,
                'skipped_users': skipped_users,
                'removed_users': removed_users,
                'total_processed': len(processed_users),
                'total_skipped': len(skipped_users),
                'total_removed': len(removed_users)
            },
            'time_taken': f"{time.time() - start_time:.3f}s"
        }, 200
    except Exception as e:
        return {
            'status': 'error',
            'message': str(e),
            'time_taken': f"{time.time() - start_time:.3f}s"
        }, 500

def delete_user_from_h5(file_path, user_name):
    if not os.path.exists(file_path):
        return f"Error: File '{file_path}' does not exist."

    try:
        with h5py.File(file_path, 'a') as h5file:
            if user_name in h5file:
                del h5file[user_name]
                return f"User '{user_name}' successfully deleted from '{file_path}'."
            else:
                return f"Error: User '{user_name}' not found in '{file_path}'."
    except Exception as e:
        return f"Error: Unable to delete user. Details: {str(e)}"
