"""
Setup MySQL Database untuk Prediksi Stok Bahan Kue
"""

import mysql.connector
from mysql.connector import Error
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database Configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'prediksi_stok_db'
}

# Products list
PRODUCTS = [
    {'name': 'Tepung Terigu 1kg', 'category': 'Tepung', 'price': 12000, 'current_stock': 4.000, 'min_stock': 10.000},
    {'name': 'Telur 1kg', 'category': 'Telur', 'price': 25000, 'current_stock': 21.200, 'min_stock': 5.000},
    {'name': 'Gula Pasir 1kg', 'category': 'Gula', 'price': 14000, 'current_stock': 18.200, 'min_stock': 8.000},
    {'name': 'Mentega 500gr', 'category': 'Mentega', 'price': 10000, 'current_stock': 10.600, 'min_stock': 5.000},
    {'name': 'Susu Bubuk', 'category': 'Susu', 'price': 20000, 'current_stock': 14.000, 'min_stock': 4.000},
    {'name': 'Ragi', 'category': 'Bahan Tambahan', 'price': 5000, 'current_stock': 10.000, 'min_stock': 0.000},
    {'name': 'Baking Powder', 'category': 'Bahan Tambahan', 'price': 5000, 'current_stock': 9.960, 'min_stock': 2.000},
    {'name': 'Cokelat Bubuk 250gr', 'category': 'Cokelat', 'price': 15000, 'current_stock': 9.000, 'min_stock': 3.000},
    {'name': 'Keju Parut 250gr', 'category': 'Keju', 'price': 20000, 'current_stock': 9.000, 'min_stock': 2.000},
]

def create_database():
    """Create database if not exists"""
    try:
        connection = mysql.connector.connect(
            host=DB_CONFIG['host'],
            user=DB_CONFIG['user'],
            password=DB_CONFIG['password']
        )
        cursor = connection.cursor()
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_CONFIG['database']}")
        logger.info(f"[OK] Database '{DB_CONFIG['database']}' created successfully")
        cursor.close()
        connection.close()
        return True
    except Error as err:
        print(f"[ERROR] Error creating database: {err}")
        return False

def create_tables():
    """Create tables in database"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()

        # Products table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL UNIQUE,
            category VARCHAR(100) NOT NULL,
            product_type VARCHAR(20) DEFAULT 'Bahan',
            unit VARCHAR(20) DEFAULT 'kg',
            price INT NOT NULL,
            current_stock DECIMAL(10,3) NOT NULL DEFAULT 0,
            min_stock DECIMAL(10,3) NOT NULL DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        logger.info("[OK] Products table created successfully")

        # Transactions table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS transactions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_name VARCHAR(255) NOT NULL,
            category VARCHAR(100) NOT NULL,
            quantity INT NOT NULL,
            unit_price INT NOT NULL,
            total_price INT NOT NULL,
            transaction_date DATE NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_name) REFERENCES products(name)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        logger.info("[OK] Transactions table created successfully")

        # Stock Usage History Table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS stock_usage_history (
            id INT AUTO_INCREMENT PRIMARY KEY,
            recipe_name VARCHAR(255),
            production_quantity INT,
            product_id INT NOT NULL,
            product_name VARCHAR(255) NOT NULL,
            quantity_used FLOAT NOT NULL,
            unit VARCHAR(50),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        logger.info("[OK] Stock Usage History table created successfully")

        # Predictions table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS predictions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_name VARCHAR(255) NOT NULL,
            category VARCHAR(100) NOT NULL,
            unit_price INT NOT NULL,
            prediction_date DATE NOT NULL,
            predicted_quantity INT NOT NULL,
            raw_value FLOAT,
            estimated_total_price INT,
            estimated_needs TEXT,
            accuracy_r2 FLOAT,
            error_mae FLOAT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        logger.info("[OK] Predictions table created successfully")

        # Login table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS login (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            email VARCHAR(100) NOT NULL UNIQUE,
            username VARCHAR(50) NOT NULL UNIQUE,
            password VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        logger.info("[OK] Login table created successfully")

        # Password reset OTP table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS password_reset_otps (
            id INT AUTO_INCREMENT PRIMARY KEY,
            login_id INT NOT NULL,
            email VARCHAR(100) NOT NULL,
            otp_code VARCHAR(10) NOT NULL,
            expires_at DATETIME NOT NULL,
            is_used TINYINT(1) DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (login_id) REFERENCES login(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        logger.info("[OK] Password reset OTP table created successfully")

        # Recipes table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS recipes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            recipe_name VARCHAR(255) NOT NULL UNIQUE,
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        logger.info("[OK] Recipes table created successfully")

        # Recipe Ingredients table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS recipe_ingredients (
            id INT AUTO_INCREMENT PRIMARY KEY,
            recipe_id INT NOT NULL,
            product_name VARCHAR(255) NOT NULL,
            quantity_needed FLOAT NOT NULL,
            unit VARCHAR(50) NOT NULL,
            FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        logger.info("[OK] Recipe Ingredients table created successfully")

        connection.commit()
        cursor.close()
        connection.close()
        return True
    except Error as err:
        print(f"[ERROR] Error creating tables: {err}")
        return False


def insert_default_products():
    """Insert default products"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()

        for product in PRODUCTS:
            try:
                cursor.execute(
                    "INSERT INTO products (name, category, price, current_stock, min_stock) VALUES (%s, %s, %s, %s, %s)",
                    (product['name'], product['category'], product['price'], product.get('current_stock', 0), product.get('min_stock', 0))
                )
            except:
                pass

        connection.commit()
        cursor.execute("SELECT COUNT(*) FROM products")
        count = cursor.fetchone()[0]
        logger.info(f"[OK] Inserted {count} default products")
        cursor.close()
        connection.close()
        return True
    except Error as err:
        print(f"[ERROR] Error inserting products: {err}")
        return False

def insert_default_login():
    """Insert default login account"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()

        cursor.execute("""
        INSERT INTO login (name, email, username, password)
        VALUES (%s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            name = VALUES(name),
            email = VALUES(email),
            username = VALUES(username)
        """, ('Ibu Sulastri', 'sulastri.aritanto10@gmail.com', 'admin', 'password'))

        connection.commit()
        logger.info("[OK] Default login account ready")
        cursor.close()
        connection.close()
        return True
    except Error as err:
        print(f"[ERROR] Error inserting login account: {err}")
        return False

def verify_connection():
    """Verify database connection"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()
        cursor.execute("SELECT COUNT(*) FROM products")
        count = cursor.fetchone()[0]
        logger.info(f"[OK] Database connected! Found {count} products")
        cursor.close()
        connection.close()
        return True
    except Error as err:
        print(f"[ERROR] Connection error: {err}")
        return False

def main():
    print("=" * 60)
    print("SETUP DATABASE MYSQL - PREDIKSI STOK BAHAN KUE")
    print("=" * 60)
    print()
    print("Database Configuration:")
    print(f"  Host: {DB_CONFIG['host']}")
    print(f"  User: {DB_CONFIG['user']}")
    print(f"  Database: {DB_CONFIG['database']}")
    print()

    if not create_database():
        return

    if not create_tables():
        return

    if not insert_default_products():
        return

    if not insert_default_login():
        return

    verify_connection()

    print()
    print("=" * 60)
    print("Database setup completed successfully!")
    print("=" * 60)

if __name__ == "__main__":
    main()
