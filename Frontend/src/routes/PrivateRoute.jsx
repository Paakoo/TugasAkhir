import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';

const PrivateRoute = () => {
  const token = sessionStorage.getItem('token');
  const role = sessionStorage.getItem('role')?.toLowerCase(); // Menghindari error jika role null

  if (!token || role !== 'admin') {
    console.warn("Akses ditolak: Token tidak ada atau role bukan admin");
    return <Navigate to="/login" replace />;
  }

  console.log("✅ Token:", token);
  console.log("✅ Role:", role);

  return <Outlet />;
};

export default PrivateRoute;
