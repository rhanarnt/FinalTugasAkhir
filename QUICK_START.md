# Quick Command Reference - MySQL Integration

## 🚀 Setup & Run (Copy-Paste Ready)

### 1️⃣ Install Python Dependencies

```bash
cd c:\fluuter.u\permintaandanprediksi_stok_bahan_kue\finalproject\ml_model
pip install -r requirements.txt
```

### 2️⃣ Setup MySQL Database

```bash
python database_setup.py
```

**Expected Output:**

```
============================================================
SETUP DATABASE MYSQL - PREDIKSI STOK BAHAN KUE
============================================================

Database Configuration:
  Host: localhost
  User: root
  Database: prediksi_stok_db

✅ Database 'prediksi_stok_db' created successfully
✅ Products table created successfully
✅ Transactions table created successfully
✅ Predictions table created successfully
✅ Inserted 8 default products
✅ Database setup completed successfully!
✅ Database connected! Found 8 products
```

### 3️⃣ Start Flask API

```bash
python app.py
```

**Expected Output:**

```
================================================================================
Starting Prediksi Stok API
================================================================================
Model: RandomForest
Accuracy (R²): 0.9964
Features: 10
Endpoints: /health, /metadata, /info, /prediksi, /batch-prediksi, /products, /transactions, /predictions
Access API at: http://localhost:5000
================================================================================
 * Running on http://0.0.0.0:5000
```

### 4️⃣ Run Flutter App (In new terminal)

```bash
cd c:\fluuter.u\permintaandanprediksi_stok_bahan_kue\finalproject
flutter run
```

---

## ✅ Test Endpoints (Postman / cURL)

### Test 1: Health Check

```bash
curl http://localhost:5000/health
```

### Test 2: Get All Products

```bash
curl http://localhost:5000/products
```

### Test 3: Save Transaction

```bash
curl -X POST http://localhost:5000/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "product_name": "Tepung Terigu 1kg",
    "category": "Tepung",
    "quantity": 5,
    "unit_price": 15000,
    "total_price": 75000,
    "transaction_date": "2024-04-05"
  }'
```

### Test 4: Get Transactions

```bash
curl http://localhost:5000/transactions
```

### Test 5: Save Prediction

```bash
curl -X POST http://localhost:5000/predictions \
  -H "Content-Type: application/json" \
  -d '{
    "product_name": "Tepung Terigu 1kg",
    "category": "Tepung",
    "unit_price": 15000,
    "prediction_date": "2024-04-05",
    "predicted_quantity": 45,
    "raw_value": 44.8,
    "estimated_total_price": 672000,
    "accuracy_r2": 0.9964,
    "error_mae": 2.51
  }'
```

---

## 🔧 Troubleshooting Commands

### Check MySQL is running

```bash
# Windows cmd
tasklist | find "MySQL"

# macOS
brew services list | grep mysql

# Linux
sudo systemctl status mysql
```

### Check if port 5000 is available

```bash
# Windows
netstat -ano | findstr :5000

# macOS/Linux
lsof -i :5000
```

### View MySQL data

```bash
# Login to MySQL
mysql -u root -p prediksi_stok_db

# View all products
SELECT * FROM products;

# View all transactions
SELECT * FROM transactions;

# View all predictions
SELECT * FROM predictions;

# Count transactions
SELECT COUNT(*) as total_transactions FROM transactions;

# Exit
exit
```

### Stop/Restart Flask API

Press `Ctrl + C` in terminal running Flask

### Reset Database

```bash
# Delete and recreate
python database_setup.py

# Or manually in MySQL
DROP DATABASE prediksi_stok_db;
# Then run database_setup.py
```

---

## 📱 Flutter Integration

### In Transaction Screen - Automatic Integration

When user presses "Simpan Transaksi":

1. ✅ Form validation
2. ✅ Calls `MLService.saveTransaction()`
3. ✅ Saves to MySQL database
4. ✅ Shows success message
5. ✅ Updates local UI

### To use in other screens:

```dart
// Import
import 'package:finalproject/services/ml_service.dart';

// Get products
List<Map<String, dynamic>> products = await MLService.getProducts();

// Save transaction
bool success = await MLService.saveTransaction(
  productName: 'Tepung Terigu 1kg',
  category: 'Tepung',
  quantity: 5,
  unitPrice: 15000,
  totalPrice: 75000,
  transactionDate: '2024-04-05',
);

// Get transactions
List<Map<String, dynamic>> transactions = await MLService.getTransactions();

// Save prediction
bool success = await MLService.savePrediction(
  productName: 'Tepung Terigu 1kg',
  category: 'Tepung',
  unitPrice: 15000,
  predictionDate: '2024-04-05',
  predictedQuantity: 45,
  rawValue: 44.8,
  estimatedTotalPrice: 672000,
  accuracyR2: 0.9964,
  errorMae: 2.51,
);
```

---

## 📊 Database Files Modified

**Backend:**

- ✨ `ml_model/database_setup.py` - NEW (Database initialization)
- ✨ `ml_model/MYSQL_SETUP.md` - NEW (Setup guide)
- ✏️ `ml_model/app.py` - UPDATED (6 new endpoints)
- ✏️ `ml_model/requirements.txt` - UPDATED (MySQL dependencies)

**Frontend:**

- ✏️ `lib/services/ml_service.dart` - UPDATED (5 new methods)
- ✏️ `lib/screens/transaction_screen.dart` - UPDATED (API integration)

---

## 🎯 What's Working Now

✅ Flutter ↔ Flask API ↔ MySQL
✅ Products saved in database
✅ Transactions saved to MySQL
✅ Predictions saved to MySQL
✅ Real-time data persistence
✅ Transaction history retrieval

---

## 📚 Documentation

- **Full Setup Guide**: `ml_model/MYSQL_SETUP.md`
- **Integration Details**: `MYSQL_INTEGRATION.md`
- **API Reference**: `ml_model/app.py` (comments)
- **DB Schema**: `MYSQL_INTEGRATION.md` (Database Schema section)

---

**Everything is ready!** 🎉

Just run the 4 steps above and your app will be connected to MySQL!
