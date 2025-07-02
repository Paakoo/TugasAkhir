import React, { useState, useEffect } from 'react';
import { ChevronLeft, ChevronRight, Download, Calendar, Search, Filter } from 'lucide-react';
import { getAttendanceDataMonth } from '../api/attendance';

const AttendanceLog = () => {
  const [currentDate, setCurrentDate] = useState(new Date());
  const [attendance, setAttendance] = useState([]);
  const [filteredAttendance, setFilteredAttendance] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [filters, setFilters] = useState({ status: 'all', department: 'all' });
  const [loading, setLoading] = useState(false);

  const month = currentDate.toISOString().substring(0, 7);

  const determineStatus = (checkInTime) => {
    if (!checkInTime) return 'Alfa';
    const checkIn = new Date(`1970-01-01T${checkInTime}`);
    const batas = new Date(`1970-01-01T08:00:00`);
    return checkIn > batas ? 'Terlambat' : 'Hadir';
  };

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      const startDate = `${month}-01`;
      const endDate = new Date(new Date(startDate).getFullYear(), new Date(startDate).getMonth() + 1, 0)
        .toISOString()
        .substring(0, 10);

      const res = await getAttendanceDataMonth(startDate, endDate);
      if (res.success) {
        const enrichedData = res.data.map((record) => ({
          ...record,
          status: determineStatus(record.checkInTime),
        }));
        setAttendance(enrichedData);
        setFilteredAttendance(enrichedData);
      }
      setLoading(false);
    };

    fetchData();
  }, [month]);

  const changeMonth = (offset) => {
    const newDate = new Date(currentDate);
    newDate.setMonth(currentDate.getMonth() + offset);
    setCurrentDate(newDate);
  };

  useEffect(() => {
    let filtered = attendance;
    if (searchQuery) {
      filtered = filtered.filter(record =>
        record.employee.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        record.employee.employeeId.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }
    if (filters.status !== 'all') {
      filtered = filtered.filter(record => record.status === filters.status);
    }
    if (filters.department !== 'all') {
      filtered = filtered.filter(record => record.employee.department === filters.department);
    }
    setFilteredAttendance(filtered);
  }, [searchQuery, filters, attendance]);

  const exportToCSV = () => {
    if (!attendance || attendance.length === 0) {
      alert("Tidak ada data untuk diekspor.");
      return;
    }
  
    const headers = ['Tanggal', 'Jam Masuk', 'ID Karyawan', 'Nama', 'Office', 'Jenis Kerja','Status', 'Latitude', 'Longitude'];
  
    const rows = attendance.map(record => [
      record.date,
      record.checkInTime,
      record.employee.employeeId,
      record.employee.name,
      record.employee.office,
      record.workType,
      record.status,
      record.location?.lat || '',
      record.location?.lng || ''
    ]);
  
    const csvContent =
      '\uFEFF' + // UTF-8 BOM supaya Excel bisa baca
      [headers, ...rows]
        .map(row =>
          row.map(cell => `"${(cell ?? '').toString().replace(/"/g, '""')}"`).join(';')
        )
        .join('\n');
  
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', `absensi-${month || 'laporan'}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };
  

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <h1 className="text-2xl font-bold text-gray-800">Laporan Absensi</h1>
        <div className="flex items-center space-x-2">
          <button onClick={() => changeMonth(-1)} className="p-2 rounded-lg border border-gray-300 hover:bg-gray-100">
            <ChevronLeft size={20} />
          </button>
          <div className="flex items-center px-4 py-2 bg-white rounded-lg border border-gray-300">
            <Calendar size={20} className="text-gray-500 mr-2" />
            <span className="font-medium">
              {new Intl.DateTimeFormat('id-ID', { month: 'long', year: 'numeric' }).format(currentDate)}
            </span>
          </div>
          <button onClick={() => changeMonth(1)} className="p-2 rounded-lg border border-gray-300 hover:bg-gray-100">
            <ChevronRight size={20} />
          </button>
          <button onClick={exportToCSV} className="flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 ml-2">
            <Download size={18} className="mr-2" />Export
          </button>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div className="relative w-full sm:w-64">
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Cari nama atau ID karyawan..."
            className="w-full py-2 pl-10 pr-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <Search size={18} className="text-gray-400" />
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-3 w-full sm:w-auto">
          <div className="flex items-center">
            <Filter size={18} className="text-gray-500 mr-2" />
            <span className="text-sm text-gray-500 mr-2">Filter:</span>
          </div>
          <select
            value={filters.status}
            onChange={(e) => setFilters({ ...filters, status: e.target.value })}
            className="py-2 px-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm"
          >
            <option value="all">Semua Status</option>
            <option value="Hadir">Hadir</option>
            <option value="Terlambat">Terlambat</option>
          </select>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        {loading ? (
          <div className="p-12 text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-500 mx-auto"></div>
            <p className="mt-4 text-gray-600">Memuat data absensi...</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tanggal</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Karyawan</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Office</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Work Type</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Check In</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredAttendance.length > 0 ? (
                  filteredAttendance.map((record, index) => (
                    <tr key={index} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{record.date}</td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="ml-4">
                            <div className="text-sm font-medium text-gray-900">{record.employee.name}</div>
                            <div className="text-xs text-gray-500">{record.employee.employeeId}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{record.employee.office}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{record.workType || '-'}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{record.checkInTime || '-'}</td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${
                          record.status === 'Hadir' ? 'bg-green-100 text-green-800' :
                          record.status === 'Terlambat' ? 'bg-yellow-100 text-yellow-800' :
                          record.status === 'Izin' ? 'bg-blue-100 text-blue-800' :
                          record.status === 'Sakit' ? 'bg-purple-100 text-purple-800' :
                          'bg-red-100 text-red-800'
                        }`}>
                          {record.status}
                        </span>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan="6" className="px-6 py-12 text-center text-gray-500">
                      {searchQuery || filters.status !== 'all' || filters.department !== 'all' ? (
                        <>
                          <p className="font-medium">Tidak ada data yang sesuai dengan filter</p>
                          <p className="mt-1">Coba ubah filter atau cari dengan kata kunci lain</p>
                        </>
                      ) : (
                        <>
                          <p className="font-medium">Tidak ada data absensi untuk bulan ini</p>
                          <p className="mt-1">Data akan muncul saat karyawan melakukan absensi</p>
                        </>
                      )}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};

export default AttendanceLog;