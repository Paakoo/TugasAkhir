import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { loginUser } from '../api/auth';

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');

    try {
      const response = await loginUser(email, password);
      console.log("Login Response:", response);

      if (!response.data || !response.data['token']) {
        setError('Login gagal! Token tidak ditemukan.');
        return;
      }

      if (response.data['role'] !== 'admin') {
        setError('Akses ditolak! Hanya admin yang bisa masuk.');
        return;
      }

      // Simpan token dan role di sessionStorage agar tidak tersimpan permanen
      sessionStorage.setItem('token', response.data['token']);
      sessionStorage.setItem('role', response.data['role']);

      console.log("✅ Token:", response.token);
      console.log("✅ Role:", response.role);

      navigate('/');
    } catch (err) {
      console.error("Login Error:", err);
      setError('Email atau password salah');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 px-4">
      <div className="bg-white p-8 rounded-lg shadow-md w-full max-w-md">
        <h2 className="text-2xl font-bold mb-6 text-gray-800 text-center">Login Admin</h2>

        {error && <p className="text-red-500 text-sm mb-4 text-center">{error}</p>}

        <form onSubmit={handleLogin} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
            <input 
              type="email" 
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-2 focus:outline-blue-500 focus:border-transparent"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Password</label>
            <input 
              type="password" 
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-2 focus:outline-blue-500 focus:border-transparent"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          <button type="submit" className="w-full bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700 transition duration-200">
            Login
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;
