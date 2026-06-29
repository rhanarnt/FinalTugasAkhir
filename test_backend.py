#!/usr/bin/env python3
"""
Simple backend connectivity test using built-in urllib (dependency-free)
Run: python test_backend.py
"""

import json
from datetime import datetime
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

# Change this to your backend URL
BACKEND_URL = "http://127.0.0.1:5000"  # Default to localhost for easier local checks

def make_request(url, method="GET", data=None, headers=None, timeout=5):
    if headers is None:
        headers = {}
    
    req_data = None
    if data is not None:
        req_data = json.dumps(data).encode('utf-8')
        if 'Content-Type' not in headers:
            headers['Content-Type'] = 'application/json'
            
    req = Request(url, data=req_data, headers=headers, method=method)
    try:
        with urlopen(req, timeout=timeout) as response:
            status_code = response.status
            body = response.read().decode('utf-8')
            try:
                json_data = json.loads(body)
            except json.JSONDecodeError:
                json_data = body
            return status_code, json_data
    except HTTPError as e:
        body = e.read().decode('utf-8', errors='replace')
        try:
            json_data = json.loads(body)
        except json.JSONDecodeError:
            json_data = body
        return e.code, json_data
    except URLError as e:
        raise RuntimeError(f"Connection failed: {e.reason}")

def test_health():
    """Test if backend is running"""
    try:
        print("\n[TEST 1] Health Check")
        url = f"{BACKEND_URL}/health"
        print(f"URL: {url}")
        status, data = make_request(url)
        print(f"Status: {status}")
        print(f"Response: {data}")
        return status == 200
    except Exception as e:
        print(f"[ERROR] Error: {e}")
        return False

def test_get_products():
    """Test get products endpoint"""
    try:
        print("\n[TEST 2] Get Products")
        url = f"{BACKEND_URL}/products"
        print(f"URL: {url}")
        status, data = make_request(url)
        print(f"Status: {status}")
        if isinstance(data, dict):
            print(f"Total products: {data.get('total', 0)}")
            if data.get('products'):
                print(f"First product: {data['products'][0]}")
        else:
            print(f"Response: {data}")
        return status == 200
    except Exception as e:
        print(f"[ERROR] Error: {e}")
        return False

def test_create_product():
    """Test create product endpoint"""
    try:
        print("\n[TEST 3] Create Product")
        url = f"{BACKEND_URL}/products"
        print(f"URL: {url}")

        payload = {
            "name": f"Test Produk {datetime.now().strftime('%H%M%S')}",
            "category": "Test",
            "price": 10000,
            "current_stock": 5
        }
        print(f"Payload: {json.dumps(payload, indent=2)}")

        status, data = make_request(url, method="POST", data=payload)
        print(f"Status: {status}")
        print(f"Response: {data}")
        return status in [201, 409]
    except Exception as e:
        print(f"[ERROR] Error: {e}")
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
        status = "[OK] PASS" if result else "[X] FAIL"
        print(f"  {status}: {test_name}")

    print("="*80)

    all_passed = all(result for _, result in tests)
    if all_passed:
        print("\n[OK] Backend is working correctly!")
    else:
        print("\n[X] Some tests failed. Check your backend connection.")
