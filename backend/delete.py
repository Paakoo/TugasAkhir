import h5py
import os

def delete_user_from_h5(file_path, user_name):
    file_path = "model/ds_model_face.h5"
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

# Example usage
if __name__ == "__main__":
    file_path = "model/ds_model_face.h5"
    user_name = input("Enter the name of the user to delete: ")
    result = delete_user_from_h5(file_path, user_name)
    print(result)
