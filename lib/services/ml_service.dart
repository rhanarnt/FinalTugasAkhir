import 'package:http/http.dart' as http;
import 'dart:convert';

class MLService {
  // API URL - Change based on environment
  static const String baseUrl = 'http://127.0.0.1:5000';
  // For remote access: 'http://192.168.1.75:5000'

  static const int timeoutSeconds = 30;

  /// Health Check - Test if API is running
  static Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }

  /// Get Metadata - Retrieve model information
  static Future<Map<String, dynamic>> getMetadata() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/metadata'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Failed to get metadata'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Simplified Prediction - For UI use
  static Future<Map<String, dynamic>> simplePrediksi({
    required String productName,
    required String category,
    required int unitPrice,
    DateTime? predictionDate,
  }) async {
    try {
      final date = predictionDate ?? DateTime.now();

      // Map product names to encoded values (adjust based on your encoding)
      final productMap = {
        'Tepung Terigu 1kg': 1,
        'Telur 1kg': 2,
        'Gula Pasir 1kg': 3,
        'Susu Bubuk': 4,
        'Cokelat Bubuk 250gr': 5,
        'Mentega 500gr': 6,
        'Keju Parut 250gr': 7,
        'Baking Powder': 8,
      };

      final categoryMap = {
        'Tepung': 1,
        'Telur': 2,
        'Gula': 3,
        'Susu': 4,
        'Cokelat': 5,
        'Mentega': 6,
        'Keju': 7,
        'Bahan Tambahan': 8,
      };

      final produkEncoded = productMap[productName] ?? 1;
      final kategoriEncoded = categoryMap[category] ?? 1;

      return await prediksiStok(
        tahun: date.year,
        bulan: date.month,
        hari: date.day,
        hariDalamMinggu: date.weekday,
        hariMinggu: date.weekday,
        hargaSatuanUpdate: unitPrice,
        totalHargaUpdate: unitPrice, // Simplified
        produkEncoded: produkEncoded,
        namaProdukEncoded: produkEncoded,
        kategoriProdukEncoded: kategoriEncoded,
      );
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Single Prediction - Predict stock demand
  static Future<Map<String, dynamic>> prediksiStok({
    required int tahun,
    required int bulan,
    required int hari,
    required int hariDalamMinggu,
    required int hariMinggu,
    required int hargaSatuanUpdate,
    required int totalHargaUpdate,
    required int produkEncoded,
    required int namaProdukEncoded,
    required int kategoriProdukEncoded,
  }) async {
    try {
      final data = {
        'tahun': tahun,
        'bulan': bulan,
        'hari': hari,
        'hari_dalam_minggu': hariDalamMinggu,
        'hari_minggu': hariMinggu,
        'harga_satuan_update': hargaSatuanUpdate,
        'total_harga_update': totalHargaUpdate,
        'produk_encoded': produkEncoded,
        'nama_produk_encoded': namaProdukEncoded,
        'kategori_produk_encoded': kategoriProdukEncoded,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/prediksi'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Batch Prediction - Predict multiple items
  static Future<Map<String, dynamic>> batchPrediksi(
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final data = {'items': items};

      final response = await http
          .post(
            Uri.parse('$baseUrl/batch-prediksi'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Get API Info
  static Future<Map<String, dynamic>> getInfo() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/info'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Failed to get info'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  // ========================================================================
  // DATABASE ENDPOINTS - PRODUCTS & TRANSACTIONS
  // ========================================================================

  /// Get all products from database
  static Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['products']);
        }
      }
      return [];
    } catch (e) {
      print('Get products error: $e');
      return [];
    }
  }

  /// Get specific product by ID
  static Future<Map<String, dynamic>?> getProduct(int productId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products/$productId'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['product'];
        }
      }
      return null;
    } catch (e) {
      print('Get product error: $e');
      return null;
    }
  }

  /// Save transaction to database
  static Future<bool> saveTransaction({
    required String productName,
    required String category,
    required int quantity,
    required int unitPrice,
    required int totalPrice,
    required String transactionDate, // Format: 'YYYY-MM-DD'
  }) async {
    try {
      final data = {
        'product_name': productName,
        'category': category,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': totalPrice,
        'transaction_date': transactionDate,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/transactions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Save transaction error: $e');
      return false;
    }
  }

  /// Get transaction history from database
  static Future<List<Map<String, dynamic>>> getTransactions({
    int limit = 100,
    int offset = 0,
    String? productName,
  }) async {
    try {
      var url = '$baseUrl/transactions?limit=$limit&offset=$offset';
      if (productName != null && productName.isNotEmpty) {
        url += '&product_name=$productName';
      }

      final response = await http
          .get(Uri.parse(url))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['transactions']);
        }
      }
      return [];
    } catch (e) {
      print('Get transactions error: $e');
      return [];
    }
  }

  /// Save prediction result to database
  static Future<bool> savePrediction({
    required String productName,
    required String category,
    required int unitPrice,
    required String predictionDate, // Format: 'YYYY-MM-DD'
    required int predictedQuantity,
    double? rawValue,
    int? estimatedTotalPrice,
    double? accuracyR2,
    double? errorMae,
  }) async {
    try {
      final data = {
        'product_name': productName,
        'category': category,
        'unit_price': unitPrice,
        'prediction_date': predictionDate,
        'predicted_quantity': predictedQuantity,
        if (rawValue != null) 'raw_value': rawValue,
        if (estimatedTotalPrice != null) 'estimated_total_price': estimatedTotalPrice,
        if (accuracyR2 != null) 'accuracy_r2': accuracyR2,
        if (errorMae != null) 'error_mae': errorMae,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/predictions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Save prediction error: $e');
      return false;
    }
  }
}
