#!/usr/bin/env python3
"""
Simple backend connectivity test
Run: python test_backend.py
"""

import requests
import json
from datetime import datetime

# Change this to your backend URL
BACKEND_URL = "http://192.168.1.2:5000"

def test_health():
    """Test if backend is running"""
    try:
        print("\n[TEST 1] Health Check")
        print(f"URL: {BACKEND_URL}/health")
        response = requests.get(f"{BACKEND_URL}/health", timeout=5)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_get_products():
    """Test get products endpoint"""
    try:
        print("\n[TEST 2] Get Products")
        print(f"URL: {BACKEND_URL}/products")
        response = requests.get(f"{BACKEND_URL}/products", timeout=5)
        print(f"Status: {response.status_code}")
        data = response.json()
        print(f"Total products: {data.get('total', 0)}")
        if data.get('products'):
            print(f"First product: {data['products'][0]}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_create_product():
    """Test create product endpoint"""
    try:
        print("\n[TEST 3] Create Product")
        print(f"URL: {BACKEND_URL}/products")

        payload = {
            "name": f"Test Produk {datetime.now().strftime('%H%M%S')}",
            "category": "Test",
            "price": 10000,
            "current_stock": 5
        }
        print(f"Payload: {json.dumps(payload, indent=2)}")

        response = requests.post(
            f"{BACKEND_URL}/products",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=5
        )
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code in [201, 409]
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    print("="*80)
    print(f"Backend Connectivity Test - {BACKEND_URL}")
    print("="*80)

    tests = [
        ("Health Check", test_health()),
        ("Get Products", test_get_products()),
        ("Create Product", test_create_product()),
    ]

    print("\n" + "="*80)
    print("SUMMARY:")
    for test_name, result in tests:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"  {status}: {test_name}")

    print("="*80)

    all_passed = all(result for _, result in tests)
    if all_passed:
        print("\n✅ Backend is working correctly!")
    else:
        print("\n❌ Some tests failed. Check your backend connection.")
