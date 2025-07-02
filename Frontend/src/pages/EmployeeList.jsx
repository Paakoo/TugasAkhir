// src/pages/EmployeeList.jsx
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Search, Edit, Trash2, UserPlus, RefreshCcw } from 'lucide-react';
import { getEmployees, deleteEmployee, updateDataset } from '../api/employees';

const EmployeeList = () => {
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    fetchEmployees();
  }, []);

  const fetchEmployees = async () => {
    setLoading(true);
    try {
      const data = await getEmployees();
      console.log("📥 Data dari API:", data); // Debugging
      setEmployees(data);
    } catch (error) {
      console.error('Error fetching employees:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id_karyawan) => {
    const confirmDelete = window.confirm("Apakah Anda yakin ingin menghapus karyawan ini?");
    if (!confirmDelete) return;

    try {
      await deleteEmployee(id_karyawan);
      alert("Karyawan berhasil dihapus!");
      fetchEmployees(); // Refresh data setelah penghapusan
    } catch (error) {
      console.error("Gagal menghapus karyawan:", error);
      alert("Terjadi kesalahan saat menghapus karyawan.");
    }
  };

  const filteredEmployees = employees.filter(employee => 
    employee.nama_karyawan.toLowerCase().includes(searchQuery.toLowerCase()) ||
    employee.id_karyawan.toString().includes(searchQuery)
  );

  const handleUpdateDataset = async () => {
    setLoading(true);
    try {
      const result = await updateDataset();
      alert("Dataset updated successfully!");
      console.log(result);
    } catch (error) {
      alert("Failed to update dataset");
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-800">Daftar Karyawan</h1>
        <div className="flex justify-between items-center space-x-5">
          <button
            onClick={handleUpdateDataset}
            className="flex items-center px-4 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
            disabled={loading}
          >
            <RefreshCcw size={20} className="mr-2" />
            {loading ? "Updating..." : "Update Karyawan"}
          </button>
          
          <Link 
          to="/employees/add" 
          className="flex items-center px-4 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
           <UserPlus size={20} className="mr-2" />
          Tambah Karyawan
          </Link>
        </div>
        
         
      </div>
      
      {/* Search input */}
      <div className="bg-white rounded-lg shadow p-4">
        <div className="relative max-w-md">
          <span className="absolute inset-y-0 left-0 flex items-center pl-3">
            <Search size={18} className="text-gray-400" />
          </span>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Cari nama atau ID karyawan..."
            className="w-full py-2 pl-10 pr-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>
      </div>
      
      {/* Employee list */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        {loading ? (
          <div className="p-12 text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-500 mx-auto"></div>
            <p className="mt-4 text-gray-600">Memuat data karyawan...</p>
          </div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ID Karyawan
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Nama Karyawan
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Email
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Role
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  {/* Aksi */}
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredEmployees.map((employee) => (
                <tr key={employee.id_karyawan} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {employee.id_karyawan}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {employee.nama_karyawan}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {employee.email}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {employee.role}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div className="flex justify-end space-x-2">
                      {/* <Link to={`/employees/edit/${employee.id_karyawan}`} className="text-indigo-600 hover:text-indigo-900">
                        <Edit size={18} />
                      </Link> */}
                      <button 
                        onClick={() => handleDelete(employee.id_karyawan)}
                        className="text-red-600 hover:text-red-900"
                      >
                        <Trash2 size={18} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              
              {filteredEmployees.length === 0 && (
                <tr>
                  <td colSpan="5" className="px-6 py-12 text-center text-gray-500">
                    {searchQuery ? (
                      <>
                        <p className="font-medium">Tidak ada hasil untuk "{searchQuery}"</p>
                        <p className="mt-1">Coba kata kunci lain atau tambahkan karyawan baru</p>
                      </>
                    ) : (
                      <>
                        <p className="font-medium">Tidak ada data karyawan</p>
                        <p className="mt-1">Mulai dengan menambahkan karyawan baru</p>
                      </>
                    )}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
};

export default EmployeeList;
