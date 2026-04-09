# 🔌 INTEGRASI API FLASK KE FLUTTER - SELESAI ✅

## ✅ Yang Sudah Dibuat

### 1. **pubspec.yaml** - Updated dengan dependencies

```yaml
dependencies:
  http: ^1.1.0 # HTTP Client untuk API
  intl: ^0.19.0 # Date formatting
```

### 2. **lib/services/ml_service.dart** - API Service

- `healthCheck()` - Verifikasi API running
- `getMetadata()` - Ambil daftar produk & kategori
- `prediksiStok()` - Single prediction
- `batchPrediksi()` - Multiple predictions

### 3. **lib/models/prediction_model.dart** - Data Models

- `PredictionRequest` - Request model
- `PredictionResult` - Response model
- `PredictionHistory` - History model

### 4. **lib/pages/prediction_page.dart** - UI Complete

- Form input lengkap (tanggal, produk, kategori, harga)
- Loading indicator saat API call
- Display hasil prediksi
- Riwayat prediksi dengan clear history
- Error handling lengkap

### 5. **lib/main.dart** - Updated Entry Point

- Hubung ke PredictionPage
- Theme configuration

---

## 🚀 CARA MENGGUNAKAN

### Step 1: Install Dependencies

```bash
cd finalproject
flutter pub get
```

### Step 2: Update API URL (PENTING!)

Edit `lib/services/ml_service.dart`:

```dart
static const String baseUrl = 'http://YOUR_IP:5000';
```

Ganti `YOUR_IP` dengan:

- **Localhost:** `http://localhost:5000` (jika testing di emulator/simulator PC sama)
- **Local Network:** `http://192.168.1.X:5000` (ganti X dengan IP dari `ipconfig`)
- **Production:** URL cloud API (Heroku, AWS, etc.)

### Step 3: Start Flask API

```bash
cd ml_model
python app.py
```

Output:

```
 * Running on http://0.0.0.0:5000
```

### Step 4: Run Flutter App

```bash
cd finalproject
flutter run
```

Atau di Android Studio:

- Press `F5` atau click Run button

### Step 5: Test Aplikasi

1. App akan loading metadata (daftar produk/kategori)
2. Akan muncul pesan: **"✅ API Connected!"** jika API terbuka
3. Isi form: Tanggal, Produk, Kategori, Harga
4. Click **PREDIKSI** button
5. Lihat hasil di bawah

---

## 📋 STRUKTUR FILE YANG DIBUAT

```
lib/
├── main.dart                    ✅ UPDATED - Entry point
├── services/
│   └── ml_service.dart          ✅ NEW - API Service
├── models/
│   └── prediction_model.dart    ✅ NEW - Data Models
└── pages/
    └── prediction_page.dart     ✅ NEW - Prediction UI

pubspec.yaml                      ✅ UPDATED - Dependencies
```

---

## 🔗 API ENDPOINTS YANG DIGUNAKAN

| Method | Endpoint          | Purpose                        |
| ------ | ----------------- | ------------------------------ |
| GET    | `/health`         | Cek API running                |
| GET    | `/metadata`       | Ambil daftar produk & kategori |
| POST   | `/prediksi`       | Single prediction              |
| POST   | `/batch-prediksi` | Batch predictions              |

---

## 📝 CONTOH FLOW

```
User Input:
├─ Tanggal: 2025-04-15
├─ Produk: Gula Pasir 1kg
├─ Kategori: Gula
└─ Harga: 12500

         ↓

Flutter App (PredictionPage):
├─ Validasi input
├─ Call MLService.prediksiStok()
└─ Display results

         ↓

Python API (app.py):
├─ Terima request
├─ Load model & encoders
├─ Preprocess data
├─ Run prediction
└─ Return JSON response

         ↓

Response ke Flutter:
{
  "status": "success",
  "prediksi": {
    "jumlah_unit": 5,
    "nilai_raw": 5.29,
    "estimasi_total_harga": 62500
  },
  "model_info": {
    "akurasi_r2": -0.0035,
    "error_mae": 2.51
  }
}

         ↓

Flutter Display:
✅ Hasil Prediksi
├─ Estimasi Jumlah: 5 unit
├─ Nilai Prediksi: 5.29 unit
├─ Estimasi Total Harga: Rp 62500
├─ Model Accuracy (R²): -0.0035
└─ Error (MAE): 2.51 unit
```

---

## ⚠️ TROUBLESHOOTING

### Error: "Connection refused"

```
❌ Problem: API tidak running atau URL salah
✅ Solution:
  1. Pastikan Flask API running: python app.py
  2. Cek URL di MLService: http://localhost:5000
  3. Cek firewall allow port 5000
```

### Error: "Failed to connect to 192.168.x.x"

```
❌ Problem: Phone tidak bisa reach API di lokal network
✅ Solution:
  1. Pastikan phone & PC di network yang sama (WiFi)
  2. Gunakan IP dari ipconfig bukan localhost
  3. Disable VPN di phone
  4. Test: curl http://192.168.x.x:5000/health
```

### Error: "No response from server"

```
❌ Problem: API response timeout (>30 detik)
✅ Solution:
  1. Check API logs untuk error
  2. Cek request ke API:
     curl -X POST http://localhost:5000/prediksi \
       -H "Content-Type: application/json" \
       -d '{"tanggal":"2025-04-15","produk":"Gula Pasir 1kg","kategori":"Gula","harga":12500}'
  3. Increase timeout di MLService (default 30s)
```

### App muncul pesan: "❌ API tidak terbuka!"

```
❌ Problem: App tidak bisa connect ke API
✅ Solution:
  1. Buka Terminal/CMD
  2. Go to ml_model folder
  3. Run: python app.py
  4. Tunggu sampai melihat: "Running on http://..."
  5. Back ke Flutter app, swipe down atau restart app
```

---

## 🎯 FITUR-FITUR

✅ **Form Input Lengkap**

- Date picker untuk tanggal
- Dropdown untuk produk (8 pilihan)
- Dropdown untuk kategori (8 pilihan)
- Input harga satuan

✅ **Form Validation**

- Cek semua field wajib diisi
- Cek harga positif

✅ **Loading State**

- Loading indicator saat fetch metadata
- Loading indicator saat submit prediksi
- Disable button saat loading

✅ **Hasil Display**

- Jumlah unit prediksi
- Nilai raw prediksi
- Estimasi total harga
- Model accuracy & error

✅ **History Tracking**

- Simpan riwayat prediksi
- Display dengan timestamp
- Tombol clear history

✅ **Error Handling**

- API connection error
- Invalid input error
- Server error
- Network timeout

✅ **API Health Check**

- Verifikasi API running saat app start
- Notification jika API tidak terbuka
- Auto retry metadata loading

---

## 📱 TESTING CHECKLIST

- [ ] API running: `python app.py` di ml_model folder
- [ ] Dependencies installed: `flutter pub get`
- [ ] Update URL di MLService (jika tidak localhost)
- [ ] Run app: `flutter run`
- [ ] Lihat "✅ API Connected!" notification
- [ ] Isi form dengan data valid
- [ ] Click PREDIKSI button
- [ ] Lihat hasil prediksi
- [ ] Add to history
- [ ] Clear history
- [ ] Test error cases (invalid product, empty field)

---

## 🔄 DEPLOYMENT SELANJUTNYA

### Untuk Local Testing:

✅ API di localhost atau local IP
✅ Flutter app di emulator/simulator/device

### Untuk Production:

⬜ Deploy Flask API ke cloud (Heroku/AWS/Railway)
⬜ Update baseUrl di MLService ke production URL
⬜ Build APK/AAB: `flutter build apk --release`
⬜ Upload ke Google Play Store

---

## 📞 QUICK REFERENCE

### File Penting:

- Backend API: `ml_model/app.py` (Flask)
- Frontend Service: `lib/services/ml_service.dart` (Flutter)
- Frontend UI: `lib/pages/prediction_page.dart` (Flutter)

### Commands:

```bash
# Start API
cd ml_model && python app.py

# Test API
curl http://localhost:5000/health

# Run Flutter
flutter run

# Build APK
flutter build apk --release
```

### API URL untuk berbagai skenario:

- Emulator/Simulator lokal: `http://localhost:5000`
- Device lokal: `http://192.168.1.X:5000` (ganti X)
- Production: `https://your-api.herokuapp.com` atau IP server

---

**Status:** ✅ INTEGRASI SELESAI & SIAP RUN
**Next Step:** `flutter run` di terminal & test aplikasi!

Generated: 2026-04-01
