// Fungsi untuk mengambil semua karyawan
export const getEmployees = async () => {
  try {
    const response = await fetch("https://aa60-20-189-117-63.ngrok-free.app/api/employees",
      {
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Content-Type': 'application/json'
        }
      }
);
    if (!response.ok) throw new Error("Failed to fetch employees");
    
    return await response.json();
  } catch (error) {
    console.error("Error fetching employees:", error);
    throw error;
  }
};

// Fungsi untuk mendapatkan detail karyawan berdasarkan ID
export const getEmployeeById = async (id) => {
  try {
    const response = await fetch(`https://aa60-20-189-117-63.ngrok-free.app/api/employees/${id}`,
      {
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Content-Type': 'application/json'
        }
      }
);
    if (!response.ok) throw new Error("Employee not found");

    return await response.json();
  } catch (error) {
    console.error(`Error fetching employee with id ${id}:`, error);
    throw error;
  }
};

// Fungsi untuk menambahkan karyawan baru
export const addEmployee = async (employeeData) => {
  try {
    const response = await fetch(BASE_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(employeeData),
    });

    if (!response.ok) throw new Error("Failed to add employee");

    return await response.json();
  } catch (error) {
    console.error("Error adding employee:", error);
    throw error;
  }
};

// Fungsi untuk mengedit data karyawan
export const updateEmployee = async (id, employeeData) => {
  try {
    const response = await fetch(`https://aa60-20-189-117-63.ngrok-free.app/api/employees/${id}`, {
      method: "PUT",
      headers: {
	'ngrok-skip-browser-warning': 'true',
        "Content-Type": "application/json",
      },
      body: JSON.stringify(employeeData),
    });

    if (!response.ok) throw new Error("Failed to update employee");

    return await response.json();
  } catch (error) {
    console.error(`Error updating employee with id ${id}:`, error);
    throw error;
  }
};

// Fungsi untuk menghapus karyawan
export const deleteEmployee = async (id_karyawan) => {
  try {
    const response = await fetch(`https://aa60-20-189-117-63.ngrok-free.app/api/employees/${id_karyawan}`, {
      method: "DELETE", headers: {
          'ngrok-skip-browser-warning': 'true',}
    });

    if (!response.ok) throw new Error("Failed to delete employee");

    return await response.json();
  } catch (error) {
    console.error(`Error deleting employee with id ${id_karyawan}:`, error);
    throw error;
  }
};

// src/api/api.js

export const updateDataset = async () => {
  const response = await fetch('https://aa60-20-189-117-63.ngrok-free.app/api/update_dataset', {
    method: 'POST', headers: {
          'ngrok-skip-browser-warning': 'true',}
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || 'Failed to update dataset');
  }

  return data;
};
