# DEPLOYMENT GUIDE - API & FLUTTER APP

## 📱 DEPLOYMENT FLUTTER APP

### Step 1: Build APK (Android)

```bash
cd c:\fluuter.u\permintaandanprediksi_stok_bahan_kue\finalproject
flutter clean
flutter pub get
flutter build apk --release
```

Output APK: `build\app\outputs\flutter-apk\app-release.apk`

### Step 2: Build AppBundle (Google Play)

```bash
flutter build appbundle --release
```

Output: `build\app\outputs\bundle\release\app-release.aab`

### Step 3: Install APK to Device

```bash
flutter install
# OR
adb install build\app\outputs\flutter-apk\app-release.apk
```

---

## 🚀 DEPLOYMENT PYTHON API

### Option A: Heroku (Cloud - Recommended)

#### 1. Install Heroku CLI

https://devcenter.heroku.com/articles/heroku-cli

#### 2. Create Procfile

File: `ml_model/Procfile`

```
web: gunicorn app:app
```

#### 3. Update requirements.txt

```bash
cd ml_model
pip freeze > requirements.txt
# Add gunicorn:
echo "gunicorn==20.1.0" >> requirements.txt
```

#### 4. Deploy to Heroku

```bash
heroku login
heroku create prediksi-stok-api
git push heroku main
```

#### 5. Access API

```
https://prediksi-stok-api.herokuapp.com/health
```

#### 6. Update Flutter API URL

`lib/services/ml_service.dart`:

```dart
static const String baseUrl = 'https://prediksi-stok-api.herokuapp.com';
```

---

### Option B: Local Server (Development)

#### 1. Keep API Running

```bash
cd ml_model
python app.py
```

#### 2. Access from Phone

Use IP address instead of localhost:

```
http://192.168.1.75:5000
```

Ganti `192.168.1.75` dengan IP lokal Anda.

#### 3. Update Flutter API URL

`lib/services/ml_service.dart`:

```dart
static const String baseUrl = 'http://192.168.1.75:5000';
```

---

### Option C: AWS EC2 (Advanced)

1. Launch EC2 instance (Ubuntu)
2. Install Python & dependencies
3. Deploy Flask with Gunicorn + Nginx
4. Get Elastic IP
5. Update Flutter API URL

---

## ✅ CHECKLIST SEBELUM DEPLOY

### Backend

- [ ] API running locally? (`python app.py`)
- [ ] All endpoints working? (Test 1-4)
- [ ] Models loaded correctly?
- [ ] CORS enabled?
- [ ] Requirements.txt updated?

### Frontend

- [ ] ML Service created? (`ml_service.dart`)
- [ ] Prediction Page created? (`prediction_page.dart`)
- [ ] main.dart updated? (imports PredictionPage)
- [ ] pubspec.yaml has `http` package?
- [ ] API URL configured?
- [ ] App builds without errors?

```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🔍 TESTING DEPLOYED APP

### 1. Test API Health

```bash
curl https://prediksi-stok-api.herokuapp.com/health
# Expected: status: "healthy"
```

### 2. Test App on Device

- Install APK
- Open app
- Fill form
- Click PREDIKSI
- Check result

---

## 🆘 COMMON DEPLOYMENT ISSUES

### Issue 1: "API tidak tersedia"

**Solution:**

- API not running? Start it: `python app.py`
- Wrong IP address? Check: `ipconfig`
- Firewall blocking port 5000?

### Issue 2: "Connection refused"

**Solution:**

- Use IP instead of localhost
- Both API & app on same WiFi?
- Firewall allows port 5000?

### Issue 3: "Endpoint tidak ditemukan"

**Solution:**

- API URL correct?
- Endpoint spelling correct? (`/prediksi` not `/prediksi/`)
- Headers correct? (`Content-Type: application/json`)

---

## 📊 DEPLOYMENT SUMMARY

| Step            | Status | Notes                     |
| --------------- | ------ | ------------------------- |
| **API Running** | ✅     | `python app.py`           |
| **Flutter UI**  | ✅     | `PredictionPage` created  |
| **ML Service**  | ✅     | `ml_service.dart` created |
| **API URL**     | ⚙️     | Configure for production  |
| **Build APK**   | ⚙️     | `flutter build apk`       |
| **Deploy API**  | ⚙️     | Choose Heroku/AWS/Local   |
| **Publish App** | ⚙️     | Google Play Store         |

---

**Status:** Ready for Production Deployment ✅
