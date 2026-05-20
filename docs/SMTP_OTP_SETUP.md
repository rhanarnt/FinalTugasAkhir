# Setup OTP Email

Fitur Lupa Password mengirim OTP lewat SMTP Gmail. Konfigurasi SMTP disimpan di file `ml_model/.env`, jadi tidak perlu mengetik environment variable setiap kali menyalakan Flask.

## 1. Siapkan App Password Gmail

Gunakan akun email:

```text
sulastri.aritanto10@gmail.com
```

Buat **App Password** dari pengaturan akun Google. Gunakan App Password itu untuk `SMTP_APP_PASSWORD`, bukan password Gmail biasa.

## 2. Simpan Konfigurasi SMTP

Pastikan file `ml_model/.env` berisi:

```text
SMTP_EMAIL=sulastri.aritanto10@gmail.com
SMTP_APP_PASSWORD=APP_PASSWORD_16_KARAKTER_DARI_GOOGLE
SMTP_SENDER_NAME=Tobaku Sulastri
```

File `.env` sudah diabaikan oleh Git supaya App Password tidak ikut tersimpan ke repository.

## 3. Jalankan Backend Flask

Di PowerShell, cukup masuk ke folder `ml_model` lalu jalankan Flask:

```powershell
cd ml_model
python app.py
```

Atau dari root project:

```powershell
python ml_model\app.py
```

## 4. Testing di Aplikasi

1. Buka halaman Login.
2. Tekan **Lupa Password?**.
3. Isi email atau username:

```text
sulastri.aritanto10@gmail.com
```

atau:

```text
admin
```

4. Tekan **Kirim OTP**.
5. Cek inbox email `sulastri.aritanto10@gmail.com`.
6. Masukkan OTP, password baru, dan konfirmasi password.

OTP berlaku selama 10 menit.
