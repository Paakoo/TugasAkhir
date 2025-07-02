import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/dashboard';
import EmployeeList from './pages/EmployeeList';
import AttendanceLog from './pages/AttendanceLog';
import TambahKaryawan from './pages/TambahKaryawan';
import Login from './pages/Login';
import Coba from './pages/Coba';
import PrivateRoute from './routes/PrivateRoute';

const App = () => {
  return (
    <BrowserRouter>
      <Routes>
        {/* Halaman Login - Bisa diakses tanpa autentikasi */}
        <Route path="/coba" element={<Coba />} />
	<Route path="/login" element={<Login />} />
        <Route path="employees/add" element={<TambahKaryawan />} />
        {/* Proteksi Rute dengan PrivateRoute */}
        <Route element={<PrivateRoute />}>
          <Route path="/" element={<Layout />}>
            <Route index element={<Dashboard />} />
            <Route path="employees" element={<EmployeeList />} />
            <Route path="attendance" element={<AttendanceLog />} />
          </Route>
        </Route>

        {/* Redirect jika rute tidak ditemukan */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
};

export default App;
