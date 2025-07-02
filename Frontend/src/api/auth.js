import axios from 'axios';


const API_URL = 'https://aa60-20-189-117-63.ngrok-free.app/api/login'; // Sesuaikan dengan URL backend Flask

export const loginUser = async (email, password) => {
    try {
      const response = await axios.post(API_URL, { email, password });
  
      // ✅ Debugging: Tampilkan response dari backend
      console.log("=== Login Response ===", response.data);
  
      return response.data;
    } catch (error) {
      // ✅ Debugging: Cek error yang terjadi
      console.error("Login Error:", error.response ? error.response.data : error.message);
      
      throw error;
    }
  };
