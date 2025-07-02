import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api';

export const getEmployees = async () => {
  const response = await axios.get(`${API_BASE_URL}/employees`);
  return response.data;
};

export const searchEmployees = async (term) => {
  const response = await axios.get(`${API_BASE_URL}/employees/search?term=${term}`);
  return response.data;
};

export const addEmployee = async (formData) => {
  const response = await axios.post(`${API_BASE_URL}/employees`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
  return response.data;
};