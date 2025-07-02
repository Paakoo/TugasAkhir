export const getAttendanceData = async (todayDate, endDate) => {
  try {
    const response = await fetch(
      `https://aa60-20-189-117-63.ngrok-free.app/api/getattendance?todayDate=${todayDate}&endDate=${endDate}`,
      {
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Content-Type': 'application/json'
        }
      }
    );

    // Debug response sebelum parse JSON
    console.log('Response status:', response.status);
    console.log('Response ok:', response.ok);

    if (!response.ok) {
      const errorText = await response.text();
      console.log('Error response:', errorText);
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error fetching attendance data:', error);
    return { success: false, data: [], message: error.message };
  }
};

export const getAttendanceDataMonth = async (startDate, endDate) => {
  try {
    const response = await fetch(    
    `https://aa60-20-189-117-63.ngrok-free.app/api/getattendanceMonth?startDate=${startDate}&endDate=${endDate}`,
      {
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Content-Type': 'application/json'
        }
      }

    );
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error fetching attendance data:', error);
    return { success: false, data: [], message: error.message };
  }
};


export const getEmployees = async () => {
  try {
      const response = await fetch('https://aa60-20-189-117-63.ngrok-free.app/api/dataemployee',
      {
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Content-Type': 'application/json'
        }
      }
      );
      
      if (!response.ok) {
          const errorText = await response.text();
          throw new Error(`HTTP error! status: ${response.status}, message: ${errorText}`);
      }
      
      const responseData = await response.json();
      
      return responseData;
  } catch (error) {
      console.error('Error fetching employees:', error);
      return {
          success: false,
          data: [],
          message: `Gagal mengambil data karyawan: ${error.message}`
      };
  }
};

// Fungsi untuk mendapatkan statistik absensi
export const getAttendanceStats = async (startDate, endDate) => {
  try {
    const attendanceData = await getAttendanceData(startDate, endDate);

    if (!attendanceData.success) {
      return {
        success: false,
        data: null,
        message: 'Gagal mengambil statistik absensi',
      };
    }

    const data = attendanceData.data;

    const totalRecords = data.length;
    const statusCounts = {
      Hadir: 0,
      Terlambat: 0,
      Izin: 0,
      Sakit: 0,
      Alfa: 0,
    };

    const departmentStats = {};
    const employeeStats = {};

    data.forEach((record) => {
      const status = record.status || 'Hadir';
      statusCounts[status] = (statusCounts[status] || 0) + 1;

      const department = record.office || 'Tidak Diketahui';

      // Statistik per departemen
      if (!departmentStats[department]) {
        departmentStats[department] = {
          total: 0,
          Hadir: 0,
          Terlambat: 0,
          Izin: 0,
          Sakit: 0,
          Alfa: 0,
        };
      }

      departmentStats[department].total += 1;
      departmentStats[department][status] += 1;

      // Statistik per karyawan
      const empId = record.employeeId;
      if (!employeeStats[empId]) {
        employeeStats[empId] = {
          name: record.employeeName,
          department,
          total: 0,
          Hadir: 0,
          Terlambat: 0,
          Izin: 0,
          Sakit: 0,
          Alfa: 0,
        };
      }

      employeeStats[empId].total += 1;
      employeeStats[empId][status] += 1;
    });

    const kehadiranPercentage = totalRecords > 0
      ? ((statusCounts['Hadir'] + statusCounts['Terlambat']) / totalRecords * 100).toFixed(2)
      : 0;

    return {
      success: true,
      data: {
        summary: {
          totalRecords,
          ...statusCounts,
          kehadiranPercentage,
        },
        departmentStats,
        employeeStats,
      },
      message: 'Statistik absensi berhasil diambil',
    };
  } catch (error) {
    console.error('Error calculating attendance stats:', error);
    return {
      success: false,
      data: null,
      message: 'Gagal mengkalkulasi statistik absensi',
    };
  }
};


// Fungsi untuk ekspor data absensi ke CSV
export const exportAttendanceToCSV = async (startDate, endDate) => {
  try {
    const attendanceData = await getAttendanceData(startDate, endDate);
    
    if (!attendanceData.success) {
      return {
        success: false,
        data: null,
        message: 'Gagal mengekspor data absensi'
      };
    }
    
    const data = attendanceData.data;
    
    // Header untuk CSV
    let csvContent = "Tanggal,ID Karyawan,Nama Karyawan,Departemen,Status,Jam Masuk,Jam Keluar\n";
    
    // Tambahkan data
    data.forEach(record => {
      csvContent += `${record.date},${record.employeeId},"${record.employeeName}",${record.department},${record.status},${record.checkInTime || ''},${record.checkOutTime || ''}\n`;
    });
    
    return {
      success: true,
      data: csvContent,
      message: 'Data absensi berhasil diekspor ke CSV'
    };
  } catch (error) {
    console.error('Error exporting attendance data:', error);
    return {
      success: false,
      data: null,
      message: 'Gagal mengekspor data absensi'
    };
  }
};










