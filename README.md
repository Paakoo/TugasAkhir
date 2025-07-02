# 🎓 Tugas Akhir - Face Recognition Attendance System

Sistem absensi karyawan berbasis pengenalan wajah menggunakan DeepFace, dengan backend Flask dan frontend React. Sistem ini memungkinkan presensi karyawan secara otomatis dan akurat, serta menyimpan data ke PostgreSQL.

---

## 🚀 Fitur Utama

- ✅ Login & otentikasi JWT
- ✅ Deteksi wajah & liveness
- ✅ Absensi berbasis waktu dan lokasi
- ✅ Dashboard admin (React)
- ✅ Database PostgreSQL

---

## 📁 Struktur Proyek

```bash
TugasAkhir/
├── backend/               # API Flask + DeepFace
├── frontend_web/          # React frontend
└── README.md              # Dokumentasi proyek
```

---

## 🧩 Kebutuhan Sistem

- Python 3.8+
- Node.js 16+
- PostgreSQL
- pip / virtualenv
- npm / yarn

---

## ⚙️ Instalasi Backend (Flask)

1. Masuk ke folder backend:

```bash
cd backend
```

2. Buat virtual environment dan aktifkan:

```bash
python -m venv venv
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows
```

3. Install dependency:

```bash
pip install -r requirements.txt
```

4. Jalankan server:

```bash
python app.py
```

> Secara default berjalan di: `http://localhost:8080`

---

## 💻 Instalasi Frontend (React)

1. Masuk ke folder React:

```bash
cd frontend_web
```

2. Install dependency:

```bash
npm install
```

3. Jalankan aplikasi:

```bash
npm run dev -- --host 0.0.0.0
```

> Secara default berjalan di: `http://localhost:5173`

---

## 🌐 Penggunaan

1. Buka browser: `http://localhost:5173`
2. Login sebagai admin atau user.
3. Lakukan presensi menggunakan kamera.
4. Data akan otomatis tersimpan di PostgreSQL.

---

## 🛠️ Pengaturan Lingkungan

Buat file `.env` di folder `backend/` dan sesuaikan:

```env
FLASK_HOST=0.0.0.0
FLASK_PORT=8080
JWT_SECRET_KEY=secret123
DATABASE_URL=postgresql://user:password@localhost:5432/db_name
DEBUG=True
```

---

## 📸 Teknologi yang Digunakan

- [DeepFace](https://github.com/serengil/deepface) - Face Recognition
- [Flask](https://flask.palletsprojects.com/) - Web backend
- [React.js](https://reactjs.org/) - UI frontend
- [PostgreSQL](https://www.postgresql.org/) - Database
- [OpenCV](https://opencv.org/) - Kamera & deteksi wajah

---

## 📦 Deployment

- Gunakan **Docker** atau **VM di Azure**
- Setup dengan **Nginx** + **Gunicorn** untuk produksi

---
