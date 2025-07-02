// src/components/Sidebar.jsx
import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { Users, Clock, LogOut, Menu, X, Home } from 'lucide-react';

const Sidebar = () => {
  const [expanded, setExpanded] = useState(true);
  const location = useLocation();
  const navigate = useNavigate();

  const handleLogout = () => {
    // Hapus token dan role dari sessionStorage
    sessionStorage.removeItem('token');
    sessionStorage.removeItem('role');

    // Arahkan ke halaman login
    navigate('/login');
  };

  const navigation = [
    { name: 'Dashboard', icon: <Home size={20} />, href: '/' },
    { name: 'Karyawan', icon: <Users size={20} />, href: '/employees' },
    { name: 'Absensi', icon: <Clock size={20} />, href: '/attendance' },
  ];

  return (
    <div className={`bg-blue-800 ${expanded ? 'w-64' : 'w-15'} transition-all duration-300 text-white flex flex-col`}>
      <div className="p-4 flex items-center justify-between">
        {expanded && <h1 className="text-xl font-bold">Admin Absensi</h1>}
        <button 
          onClick={() => setExpanded(!expanded)} 
          className="p-1 rounded-lg hover:bg-blue-600"
        >
          {expanded ? <X size={20} /> : <Menu size={20} />}
        </button>
      </div>
      
      <nav className="flex-1 mt-5 px-2">
        {navigation.map((item) => (
          <Link
            key={item.name}
            to={item.href}
            className={`flex items-center p-3 mb-2 rounded-lg transition-colors duration-200
              ${location.pathname === item.href ? 'bg-blue-600 text-white' : 'text-indigo-100 hover:bg-blue-600'}`}
          >
            <span className="mr-3">{item.icon}</span>
            {expanded && <span>{item.name}</span>}
          </Link>
        ))}
      </nav>
      
      {/* Tombol Logout */}
      <div className="p-1">
        <button
          onClick={handleLogout}
          className="flex items-center w-full p-3 mb-2 rounded-lg text-indigo-100 hover:bg-blue-600 transition-colors duration-200"
        >
          <LogOut size={20} className="mr-2" />
          {expanded && <span>Keluar</span>}
        </button>
      </div>
    </div>
  );
};

export default Sidebar;
