import React, { useState, useRef, useEffect } from 'react';
import Webcam from 'react-webcam';
import axios from 'axios';

const TambahKaryawan = () => {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    role: 'user',
    wearsGlasses: false
  });
  const [currentPhotoSet, setCurrentPhotoSet] = useState({
    type: 'front',
    withGlasses: false,
    count: 0,
    totalCaptured: {
      front: 0,
      left: 0,
      right: 0
    }
  });
  const [photos, setPhotos] = useState([]);
  const webcamRef = useRef(null);
  const [devices, setDevices] = useState([]);
  const [currentDeviceId, setCurrentDeviceId] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [cameraError, setCameraError] = useState(null);

  useEffect(() => {
    getAvailableCameras();
  }, []);

  useEffect(() => {
    let stream = null;

    const setupCamera = async () => {
      try {
        // Stop any existing streams
        if (webcamRef.current && webcamRef.current.video) {
          const currentStream = webcamRef.current.video.srcObject;
          if (currentStream) {
            currentStream.getTracks().forEach(track => track.stop());
          }
        }

        // Start new stream with selected device
        stream = await navigator.mediaDevices.getUserMedia({
          video: {
            deviceId: currentDeviceId ? { exact: currentDeviceId } : undefined,
            width: { ideal: 1280 },
            height: { ideal: 720 },
            frameRate: { ideal: 24 }
          }
        });

        if (webcamRef.current && webcamRef.current.video) {
          webcamRef.current.video.srcObject = stream;
          
          // Configure stream for continuous operation
          stream.getTracks().forEach(track => {
            track.applyConstraints({
              advanced: [
                { timeout: 0 },
                { powerSaveBlocker: true }
              ]
            });
          });
        }

        setCameraError(null);
      } catch (error) {
        console.error('Camera setup error:', error);
        setCameraError(error.message);
        showNotification('Error accessing camera: ' + error.message, true);
      }
    };

    if (currentDeviceId) {
      setupCamera();
    }

    // Cleanup function
    return () => {
      if (stream) {
        stream.getTracks().forEach(track => track.stop());
      }
    };
  }, [currentDeviceId]);

  const getAvailableCameras = async () => {
    try {
      await navigator.mediaDevices.getUserMedia({ video: true }); // Request initial permission
      const devices = await navigator.mediaDevices.enumerateDevices();
      const videoDevices = devices.filter(device => device.kind === 'videoinput');
      
      setDevices(videoDevices);
      
      if (videoDevices.length > 0 && !currentDeviceId) {
        setCurrentDeviceId(videoDevices[0].deviceId);
      }
    } catch (error) {
      console.error('Error accessing cameras:', error);
      setCameraError(error.message);
      showNotification('Error accessing cameras: ' + error.message, true);
    }
  };

  const switchCamera = async () => {
    if (isLoading) return;

    const currentIndex = devices.findIndex(device => device.deviceId === currentDeviceId);
    const nextIndex = (currentIndex + 1) % devices.length;
    setCurrentDeviceId(devices[nextIndex].deviceId);
  };

  const handleInputChange = (e) => {
    const { name, value, type } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? e.target.checked : value
    }));
  };

  const showNotification = (message, isError = false) => {
    const notification = document.createElement('div');
    notification.className = `fixed top-4 right-4 p-4 rounded-lg ${
      isError ? 'bg-red-500' : 'bg-green-500'
    } text-white shadow-lg transform translate-y-0 transition-transform duration-300 z-50`;
    notification.textContent = message;
    document.body.appendChild(notification);
    setTimeout(() => {
      notification.style.transform = 'translateY(-100%)';
      setTimeout(() => document.body.removeChild(notification), 300);
    }, 3000);
  };

  const handleSubmitForm = async (e) => {
    e.preventDefault();
    try {
      await axios.post('https://aa60-20-189-117-63.ngrok-free.app/api/save_user', formData);
      setStep(2);
      showNotification('Registration successful! Let\'s proceed with photo capture');
    } catch (error) {
      showNotification('Failed to submit registration: ' + error.message, true);
    }
  };

  const capturePhoto = async () => {
    if (isLoading || !webcamRef.current) return;
    setIsLoading(true);

    try {
      const photo = webcamRef.current.getScreenshot();
      if (!photo) {
        throw new Error('Failed to capture photo');
      }

      const angleMapping = {
        front: 'front',
        left: 'left',
        right: 'right'
      };

      const payload = {
        angle: angleMapping[currentPhotoSet.type],
        count: currentPhotoSet.withGlasses ? 
          `with_glasses_${currentPhotoSet.totalCaptured[currentPhotoSet.type] + 1}` : 
          `no_glasses_${currentPhotoSet.totalCaptured[currentPhotoSet.type] + 1}`,
        image: photo,
        username: formData.name,
        withGlasses: currentPhotoSet.withGlasses
      };

      const response =  await axios.post('https://aa60-20-189-117-63.ngrok-free.app/api/save_image', payload)
      if (response.data.status === 'success') {
        setPhotos(prev => [...prev, response.data.filename]);
        
        setCurrentPhotoSet(prev => {
          const newTotalCaptured = {
            ...prev.totalCaptured,
            [prev.type]: prev.totalCaptured[prev.type] + 1
          };

          const requiredPhotos = formData.wearsGlasses ? 5 : 10;
          const currentCount = prev.count + 1;

          if (currentCount >= requiredPhotos) {
            if (prev.type === 'front') {
              showNotification('Great! Now let\'s capture your left side');
              return {
                ...prev,
                type: 'left',
                count: 0,
                totalCaptured: newTotalCaptured
              };
            } else if (prev.type === 'left') {
              showNotification('Perfect! Finally, let\'s capture your right side');
              return {
                ...prev,
                type: 'right',
                count: 0,
                totalCaptured: newTotalCaptured
              };
            } else if (prev.type === 'right' && formData.wearsGlasses && !prev.withGlasses) {
              showNotification('Now let\'s repeat with your glasses on');
              return {
                type: 'front',
                withGlasses: true,
                count: 0,
                totalCaptured: {
                  front: 0,
                  left: 0,
                  right: 0
                }
              };
            } else {
              setStep(3);
              showNotification('Photo capture completed successfully!');
              return prev;
            }
          }

          return {
            ...prev,
            count: currentCount,
            totalCaptured: newTotalCaptured
          };
        });
      } else {
        throw new Error(response.data.message || 'Failed to save image');
      }
    } catch (error) {
      showNotification(error.message || 'Failed to capture and save photo', true);
    } finally {
      setIsLoading(false);
    }
  };

  const renderCameraControls = () => (
    <div className="absolute top-4 right-4 z-10">
      <button
        onClick={switchCamera}
        disabled={isLoading || devices.length <= 1}
        className="bg-gray-800 bg-opacity-50 text-white p-2 rounded-full hover:bg-opacity-75 transition-all duration-200 disabled:opacity-50"
        title="Switch Camera"
      >
        <svg 
          xmlns="http://www.w3.org/2000/svg" 
          className="h-6 w-6" 
          fill="none" 
          viewBox="0 0 24 24" 
          stroke="currentColor"
        >
          <path 
            strokeLinecap="round" 
            strokeLinejoin="round" 
            strokeWidth={2} 
            d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" 
          />
        </svg>
      </button>
    </div>
  );

  const renderWebcam = () => (
    <Webcam
      ref={webcamRef}
      screenshotFormat="image/jpeg"
      className="w-full"
      videoConstraints={{
        deviceId: currentDeviceId,
        width: 1280,
        height: 720,
        facingMode: "user",
        frameRate: 24
      }}
      forceScreenshotSourceSize={true}
      onUserMediaError={(error) => {
        console.error('Webcam error:', error);
        setCameraError(error.message);
        showNotification('Camera access error: ' + error.message, true);
      }}
      onUserMedia={(stream) => {
        stream.getTracks().forEach(track => {
          track.applyConstraints({
            advanced: [
              { timeout: 0 },
              { powerSaveBlocker: true }
            ]
          });
        });
      }}
    />
  );

  const renderStep = () => {
    switch (step) {
      case 1:
        return (
          <div className="bg-white rounded-xl shadow-lg p-8 w-full max-w-md">
            <h2 className="text-2xl font-bold mb-6 text-gray-800">User Registration</h2>
            <form onSubmit={handleSubmitForm} className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Nama</label>
                <input
                  type="text"
                  name="name"
                  value={formData.name}
                  onChange={handleInputChange}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-2 focus:outline-blue-500 focus:border-transparent"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
                <input
                  type="email"
                  name="email"
                  value={formData.email}
                  onChange={handleInputChange}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-2 focus:outline-blue-500 focus:border-transparent"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Role</label>
                <select
                  name="role"
                  value={formData.role}
                  onChange={handleInputChange}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-2 focus:outline-blue-500 focus:border-transparent  bg-white"
                  required
                >
                  <option value="user">User</option>
                  <option value="admin">Admin</option>
                </select>
              </div>
              <div className="flex items-center space-x-2">
                <input
                  type="checkbox"
                  id="wearsGlasses"
                  name="wearsGlasses"
                  checked={formData.wearsGlasses}
                  onChange={handleInputChange}
                  className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                />
                <label htmlFor="wearsGlasses" className="text-sm font-medium text-gray-900">
                  User memakai kacamata
                </label>
              </div>
              <button
                type="submit"
                className="w-full bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700 transition duration-200"
              >
                Continue
              </button>
            </form>
          </div>
        );

      case 2:
        return (
          <div className="bg-white rounded-xl shadow-lg p-8 w-full max-w-2xl">
            <div className="text-center mb-6">
              <h2 className="text-2xl font-bold text-gray-800 mb-2">Photo Capture</h2>
              <p className="text-red-600 font-bold">
                {currentPhotoSet.withGlasses ? 'With Glasses - ' : ''}
                {currentPhotoSet.type.charAt(0).toUpperCase() + currentPhotoSet.type.slice(1)} View
              </p>
            </div>

            <div className="mb-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
              <p className="text-blue-800">
                {currentPhotoSet.type === 'front' ? 'Look directly at the camera' :
                 currentPhotoSet.type === 'left' ? 'Turn your head slightly to the left' :
                 'Turn your head slightly to the right'}
              </p>
            </div>

            <div className="rounded-lg overflow-hidden border-2 border-gray-200 mb-6 relative">
              {renderWebcam()}
              {renderCameraControls()}
            </div>

            {cameraError && (
              <div className="mb-6 bg-red-50 border border-red-200 rounded-lg p-4">
                <p className="text-red-800">Camera Error: {cameraError}</p>
              </div>
            )}

            <div className="text-center space-y-4">
              <p className="text-sm text-gray-600">
                Photo {currentPhotoSet.count + 1} of {formData.wearsGlasses ? 5 : 10}
              </p>
              <div className="w-full bg-gray-200 rounded-full h-2 mb-4">
                <div
                  className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${(currentPhotoSet.count / (formData.wearsGlasses ? 5 : 10)) * 100}%` }}
                />
              </div>
              <button
                onClick={capturePhoto}
                disabled={isLoading || cameraError}
                className="w-full bg-green-600 text-white py-3 px-6 rounded-lg hover:bg-green-700 transition duration-200 text-lg font-medium disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isLoading ? 'Processing...' : 'Capture Photo'}
              </button>
            </div>
          </div>
        );

      case 3:
        return (
          <div className="bg-white rounded-xl shadow-lg p-8 w-full max-w-md text-center">
            <div className="mb-6">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg className="w-8 h-8 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <h2 className="text-2xl font-bold text-gray-800 mb-2">Registration Complete</h2>
              <p className="text-gray-600">All photos have been captured successfully!</p>
            </div>
            <button
              onClick={() => window.location.reload()}
              className="bg-blue-600 text-white py-2 px-6 rounded-lg hover:bg-blue-700 transition duration-200"
            >
              Start New Registration
            </button>
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center p-4">
      {renderStep()}
    </div>
  );
};

export default TambahKaryawan;