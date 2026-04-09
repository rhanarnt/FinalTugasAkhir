# MySQL Integration Summary - Prediksi Stok Bahan Kue

## ✅ What's Done

### Backend (Flask) - NEW FILES & UPDATES

#### New Files Created:

1. **`database_setup.py`** - Script untuk initialize MySQL database
   - Buat database `prediksi_stok_db`
   - Buat 3 tables: `products`, `transactions`, `predictions`
   - Insert 8 default products

2. **`MYSQL_SETUP.md`** - Comprehensive setup guide
   - MySQL installation instructions
   - Database setup steps (automatic & manual)
   - API endpoint documentation
   - Troubleshooting guide

#### Updated Files:

1. **`requirements.txt`** - Added MySQL dependencies

   ```
   flask-sqlalchemy==3.0.0
   PyMySQL==1.1.0
   ```

2. **`app.py`** - Added 6 new endpoints
   - `GET /products` - Ambil daftar produk
   - `GET /products/<id>` - Ambil 1 produk by ID
   - `POST /transactions` - Simpan transaksi
   - `GET /transactions` - Ambil history transaksi
   - `POST /predictions` - Simpan prediction results
   - Updated `/info` endpoint

### Frontend (Flutter) - UPDATES

#### Updated Files:

1. **`lib/services/ml_service.dart`** - Added 5 new methods
   - `getProducts()` - Get products from API
   - `getProduct(id)` - Get single product
   - `saveTransaction()` - Save transaction to MySQL
   - `getTransactions()` - Get transaction history
   - `savePrediction()` - Save prediction to MySQL

2. **`lib/screens/transaction_screen.dart`** - Integrated with API
   - `_submitTransaction()` now calls API
   - Added loading state during save
   - Show success/error messages
   - Data di-save ke MySQL, bukan cuma local

## 📋 Architecture

```
                    ┌─────────────────┐
                    │  FLUTTER APP    │
                    │  (Mobile)       │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Flask API      │
                    │  (Python)       │
                    │  on localhost:  │
                    │  5000           │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  MySQL Database │
                    │  localhost:3306 │
                    └─────────────────┘

Data Flow:
User Input → Flutter → API → MySQL Database
```

## 🚀 Quick Start (3 Steps)

### Step 1: Install MySQL & Setup Database

```bash
# Navigate to ml_model folder
cd c:\fluuter.u\permintaandanprediksi_stok_bahan_kue\finalproject\ml_model

# Install Python dependencies
pip install -r requirements.txt

# Setup MySQL database
python database_setup.py
```

**Expected Output:**

```
✅ Database 'prediksi_stok_db' created successfully
✅ Products table created successfully
✅ Transactions table created successfully
✅ Predictions table created successfully
✅ Inserted 8 default products
✅ Database setup completed successfully!
```

### Step 2: Start Flask API

```bash
# From ml_model folder
python app.py
```

**Expected Output:**

```
Starting Prediksi Stok API
Model: RandomForest
Accuracy (R²): 0.9964
Endpoints: /health, /metadata, /info, /prediksi, /batch-prediksi, /products, /transactions, /predictions
Access API at: http://localhost:5000
```

### Step 3: Run Flutter App

```bash
# From finalproject folder
flutter run
```

## 🔌 API Endpoints

### Products

```
GET /products
Response: {
  "status": "success",
  "total": 8,
  "products": [
    {"id": 1, "name": "Tepung Terigu 1kg", "category": "Tepung", "price": 15000, "stock": 45, ...},
    ...
  ]
}

GET /products/1
Response: {
  "status": "success",
  "product": {"id": 1, "name": "Tepung Terigu 1kg", ...}
}
```

### Transactions

```
POST /transactions
Body: {
  "product_name": "Tepung Terigu 1kg",
  "category": "Tepung",
  "quantity": 5,
  "unit_price": 15000,
  "total_price": 75000,
  "transaction_date": "2024-04-05"
}
Response: {
  "status": "success",
  "message": "Transaction saved successfully",
  "transaction_id": 1
}

GET /transactions?limit=100&offset=0
Response: {
  "status": "success",
  "total": 10,
  "transactions": [...]
}

GET /transactions?product_name=Tepung
Response: {...} // Filtered by product name
```

### Predictions

```
POST /predictions
Body: {
  "product_name": "Tepung Terigu 1kg",
  "category": "Tepung",
  "unit_price": 15000,
  "prediction_date": "2024-04-05",
  "predicted_quantity": 45,
  "raw_value": 44.8,
  "estimated_total_price": 672000,
  "accuracy_r2": 0.9964,
  "error_mae": 2.51
}
Response: {
  "status": "success",
  "message": "Prediction saved successfully",
  "prediction_id": 1
}
```

## 📊 Database Schema

### Products Table

```sql
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price INT NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL DEFAULT 'tersedia',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Transactions Table

```sql
CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    unit_price INT NOT NULL,
    total_price INT NOT NULL,
    transaction_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Predictions Table

```sql
CREATE TABLE predictions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    unit_price INT NOT NULL,
    prediction_date DATE NOT NULL,
    predicted_quantity INT,
    raw_value DOUBLE,
    estimated_total_price INT,
    accuracy_r2 DOUBLE,
    error_mae DOUBLE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🔄 Flutter Integration Examples

### Example 1: Get All Products

```dart
List<Map<String, dynamic>> products = await MLService.getProducts();
```

### Example 2: Save Transaction

```dart
bool success = await MLService.saveTransaction(
  productName: 'Tepung Terigu 1kg',
  category: 'Tepung',
  quantity: 5,
  unitPrice: 15000,
  totalPrice: 75000,
  transactionDate: '2024-04-05',
);
```

### Example 3: Get Transaction History

```dart
List<Map<String, dynamic>> transactions = await MLService.getTransactions(
  limit: 50,
  offset: 0,
  productName: null,
);
```

### Example 4: Save Prediction

```dart
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

## 📝 Files Modified/Created

### Backend

```
ml_model/
├── database_setup.py          ✨ NEW
├── MYSQL_SETUP.md             ✨ NEW
├── app.py                     ✏️ UPDATED (added 6 endpoints)
└── requirements.txt           ✏️ UPDATED (added MySQL libs)
```

### Frontend

```
lib/
├── services/
│   └── ml_service.dart        ✏️ UPDATED (added 5 methods)
└── screens/
    └── transaction_screen.dart ✏️ UPDATED (integrated with API)
```

## ✅ Verification Checklist

Before running the app:

- [ ] MySQL server installed & running
- [ ] Database setup completed (`python database_setup.py`)
- [ ] Flask API running (`python app.py`) on port 5000
- [ ] Can access `http://localhost:5000/health` in browser
- [ ] Can access `http://localhost:5000/products` in browser
- [ ] Flutter app can connect to API

## 🐛 Common Issues & Solutions

### Issue: "Can't connect to MySQL server"

**Solution**: Check MySQL is running

```bash
# Windows: Check Services
# macOS: brew services list
# Linux: sudo systemctl status mysql
```

### Issue: "Database 'prediksi_stok_db' doesn't exist"

**Solution**: Run the database setup script

```bash
python database_setup.py
```

### Issue: "Access denied for user 'root'@'localhost'"

**Solution**: Update database credentials in `app.py` and `database_setup.py`

```python
DB_PASSWORD = 'your_mysql_password'
```

### Issue: "Port 5000 already in use"

**Solution**: Change port in `app.py`

```python
app.run(port=5001)  # Use different port
```

## 🔐 Security Notes

For production use:

1. Never use `root` user without password
2. Create dedicated database user with restricted privileges
3. Use environment variables for credentials
4. Enable SSL/TLS for connections
5. Implement API authentication (JWT, OAuth)
6. Add input validation & SQL injection protection

Example:

```python
# Use environment variables
import os
DB_PASSWORD = os.getenv('DB_PASSWORD', 'default_password')
```

## 📚 Next Steps

1. ✅ Test all endpoints with Postman
2. ✅ Test Transaction Screen with real data
3. ✅ Implement Prediction Screen API integration
4. ✅ Add local caching for offline support
5. ✅ Setup authentication & user management
6. ✅ Implement data sync & backup
7. ✅ Optimize query performance with indexes
8. ✅ Add comprehensive error handling

## 📞 Support

Lihat dokumentasi lengkap di: `ml_model/MYSQL_SETUP.md`

Untuk questions atau issues, check logs:

```bash
# Flask API logs
python app.py  # Check console output

# MySQL logs
# Windows: MySQL Workbench → Administration → Server Logs
# macOS/Linux: /var/log/mysql/error.log
```

---

**Integration Status: ✅ COMPLETE!**

Data flow sekarang:

- Flutter → API → MySQL Database
- Semua transactions & predictions tersimpan di database
- Bisa diakses dari mana saja
- Persistent data untuk analysis
