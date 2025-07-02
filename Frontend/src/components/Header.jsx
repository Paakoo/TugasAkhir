// src/components/Header.jsx
import React, { useState } from 'react';

const Header = () => {
  
  return (
    <header className="bg-white shadow-sm p-4 flex items-center justify-between">
     <h1 className="text-2xl font-bold text-gray-800">Dashboard</h1>
      
      <div className="flex items-center space-x-4">
        <div className="flex items-center">
          <span className="ml-2 text-gray-700 hidden md:block">Admin</span>
        </div>
      </div>
    </header>
  );
};

export default Header;