import React, { useEffect, useState } from 'react';
import { Users, UserCheck, UserX, Clock } from 'lucide-react';
import { getAttendanceData, getEmployees } from '../api/attendance';

const getTodayDate = () => {
  const today = new Date();
  return today.toISOString().split('T')[0];
};

const getEndDate = () => {
  const today = new Date();
  today.setDate(today.getDate() + 1); // Menambahkan satu hari untuk endDate
  return today.toISOString().split('T')[0];
};

const Dashboard = () => {
  const [stats, setStats] = useState([
    { title: 'Total Karyawan', value: 0, icon: <Users />, color: 'bg-blue-500' },
    { title: 'Hadir Hari Ini', value: 0, icon: <UserCheck />, color: 'bg-green-500' },
    { title: 'Tidak Hadir', value: 0, icon: <UserX />, color: 'bg-red-500' },
    { title: 'Keterlambatan', value: 0, icon: <Clock />, color: 'bg-yellow-500' },
  ]);
  const [recentActivity, setRecentActivity] = useState([]);
  const [currentTime, setCurrentTime] = useState(new Date().toLocaleTimeString());
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentTime(new Date().toLocaleTimeString());
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        setLoading(true);
        const todayDate = getTodayDate();
        const endDate =getEndDate();
        const attendanceRes = await getAttendanceData(todayDate, endDate);
        const employeeRes = await getEmployees();

        if (!attendanceRes.success) throw new Error(attendanceRes.message || 'Gagal mengambil data absensi');
        if (!employeeRes.success) throw new Error(employeeRes.message || 'Gagal mengambil data karyawan');

        const attendanceData = attendanceRes.data;
        const employeeData = employeeRes.data;
        const totalEmployees = employeeData.length;

        const presentEmployees = attendanceData.filter(item =>
          item.status === 'Hadir' || item.checkInTime !== null
        ).length;

        const lateEmployees = attendanceData.filter(item => {
          if (!item.checkInTime) return false;
          const [hour, minute] = item.checkInTime.split(':').map(Number);
          return hour > 8 || (hour === 8 && minute > 0);
        }).length;

        const absentEmployees = totalEmployees - presentEmployees;
        setStats([
          { title: 'Total Karyawan', value: totalEmployees, icon: <Users />, color: 'bg-blue-500' },
          { title: 'Hadir Hari Ini', value: presentEmployees, icon: <UserCheck />, color: 'bg-green-500' },
          { title: 'Tidak Hadir', value: absentEmployees, icon: <UserX />, color: 'bg-red-500' },
          { title: 'Keterlambatan', value: lateEmployees, icon: <Clock />, color: 'bg-yellow-500' },
        ]);

        const recent = attendanceData
        .sort((a, b) => {
          if (!a.checkInTime) return 1;
          if (!b.checkInTime) return -1;
          return b.checkInTime.localeCompare(a.checkInTime);
        })
        .slice(0, 5)
        .map(item => {
          let status = 'Hadir';
          let action = 'Check-in';

          if (!item.checkInTime) {
            status = item.status || 'Absen';
            action = status;
            return {
              name: item.employee.name,
              action,
              time: '-',
              status
            };
          }

          const [hour, minute] = item.checkInTime.split(':').map(Number);
          if (hour > 8 || (hour === 8 && minute > 0)) status = 'Terlambat';

          return {
            name: item.employee.name,
            action,
            time: item.checkInTime.substring(0, 5),
            status
          };
        });


        setRecentActivity(recent);
        setLoading(false);
      } catch (err) {
        console.error('Error in fetchDashboardData:', err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  
  if (loading) return <div className="p-4 text-gray-600">Memuat data...</div>;
  if (error) return <div className="p-4 text-red-500">Terjadi kesalahan: {error}</div>;
  console.log(recentActivity);
  return (
    <div className="space-y-6">
      {/* Waktu Realtime */}
      <div className="text-right text-2xl text-gray-600 font-bold">
        Waktu: {currentTime}
      </div>

      {/* Stat Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, index) => (
          <div key={index} className="bg-white rounded-lg shadow p-6">
            <div className="flex justify-between items-center">
              <div>
                <p className="text-sm text-gray-500">{stat.title}</p>
                <p className="text-3xl font-bold mt-1">{stat.value}</p>
              </div>
              <div className={`${stat.color} p-3 rounded-lg text-white`}>
                {stat.icon}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Recent Activity */}
      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-800">Aktivitas Terbaru</h2>
        </div>
        <div className="p-6">
          <table className="w-full">
            <thead>
              <tr className="text-left text-gray-500 border-b">
                <th className="pb-3 font-medium">Nama</th>
                <th className="pb-3 font-medium">Aksi</th>
                <th className="pb-3 font-medium">Waktu</th>
                <th className="pb-3 font-medium">Status</th>
              </tr>
            </thead>
            <tbody>
              
              
              {recentActivity.map((activity, index) => (
                <tr key={index} className="border-b border-gray-100 hover:bg-gray-50">
                  <td className="py-4">{activity.name}</td>
                  <td className="py-4">{activity.action}</td>
                  <td className="py-4">{activity.time}</td>
                  <td className="py-4">
                    <span
                      className={`px-2 py-1 rounded-full text-xs font-medium ${
                        activity.status === 'Hadir'
                          ? 'bg-green-100 text-green-800'
                          : activity.status === 'Terlambat'
                          ? 'bg-yellow-100 text-yellow-800'
                          : 'bg-red-100 text-red-800'
                      }`}
                    >
                      {activity.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
