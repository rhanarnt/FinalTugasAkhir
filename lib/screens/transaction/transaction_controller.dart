import 'package:finalproject/models/transaction_model.dart';
import 'package:finalproject/services/ml_service.dart';
import 'package:flutter/material.dart';

class CartItem {
  final int productId;
  final String productName;
  final String category;
  final int unitPrice;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.category,
    required this.unitPrice,
    required this.quantity,
  });

  int get totalPrice => unitPrice * quantity;
}

class TransactionController extends ChangeNotifier {
  final quantityController = TextEditingController();

  DateTime? selectedDate = DateTime.now();
  bool isLoading = false;
  int selectedIndex = 2;

  final List<String> products = [];
  final Map<String, int> productIds = {};
  final Map<String, String> productCategories = {};
  final Map<String, String> productUnits = {};
  final Map<String, int> productPrices = {};
  final List<String> categories = [];

  String? selectedProduct;
  final List<CartItem> cartItems = [];
  final List<Transaction> transactions = [];

  Future<void> loadProducts() async {
    final fetchedProducts = await MLService.getProducts();

    products.clear();
    productIds.clear();
    productCategories.clear();
    productUnits.clear();
    productPrices.clear();
    categories.clear();

    for (final product in fetchedProducts) {
      final id = product['id'] ?? 0;
      final name = product['name'] ?? '';
      final category = product['category'] ?? '';
      final unit = product['unit'] ?? _defaultUnitFromCategory(category);
      final price = product['price'] ?? 0;

      if (name.isNotEmpty && id > 0) {
        products.add(name);
        productIds[name] = id;
        productCategories[name] = category;
        productUnits[name] = unit;
        productPrices[name] = price;

        if (!categories.contains(category)) {
          categories.add(category);
        }
      }
    }

    notifyListeners();
  }

  void setSelectedProduct(String? value) {
    selectedProduct = value;
    notifyListeners();
  }

  void setSelectedDate(DateTime value) {
    selectedDate = value;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  String? addToCart() {
    if (selectedProduct == null || quantityController.text.isEmpty) {
      return 'Pilih produk dan masukkan jumlah';
    }

    final quantity = int.tryParse(quantityController.text) ?? 0;
    if (quantity <= 0) {
      return 'Jumlah harus lebih dari 0';
    }

    final existingIndex = cartItems.indexWhere(
      (item) => item.productName == selectedProduct,
    );

    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += quantity;
    } else {
      cartItems.add(
        CartItem(
          productId: productIds[selectedProduct!] ?? 0,
          productName: selectedProduct!,
          category: productCategories[selectedProduct!]!,
          unitPrice: productPrices[selectedProduct!]!,
          quantity: quantity,
        ),
      );
    }

    quantityController.clear();
    notifyListeners();
    return null;
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(index);
      return;
    }

    cartItems[index].quantity = newQuantity;
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }

  int get totalPrice =>
      cartItems.fold(0, (total, item) => total + item.totalPrice);

  Future<Map<String, dynamic>> submitAllTransactions() async {
    if (cartItems.isEmpty) {
      return {'status': 'error', 'message': 'Keranjang kosong'};
    }

    isLoading = true;
    notifyListeners();

    try {
      final date = selectedDate ?? DateTime.now();
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      int successCount = 0;
      String? firstError;
      final originalCount = cartItems.length;

      for (final item in cartItems) {
        final result = await MLService.addTransactionWithStockUpdate(
          productId: item.productId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalPrice: item.totalPrice,
          transactionDate: dateStr,
        );

        if (result['status'] == 'success') {
          successCount++;
          transactions.insert(
            0,
            Transaction(
              id: transactions.length + 1,
              productName: item.productName,
              category: item.category,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              totalPrice: item.totalPrice,
              date: date,
            ),
          );
        } else {
          firstError ??= result['message'] ?? 'Transaksi gagal';
        }
      }

      cartItems.clear();
      selectedDate = DateTime.now();

      return {
        'status': 'success',
        'successCount': successCount,
        'totalCount': originalCount,
        'error': firstError,
      };
    } catch (e) {
      return {'status': 'error', 'message': 'Error: ${e.toString()}'};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createProduct({
    required String productName,
    required String category,
    required int price,
    required int initialStock,
    required String unit,
    required String productType,
  }) async {
    if (products.contains(productName)) {
      return {'status': 'error', 'message': 'Produk "$productName" sudah ada'};
    }

    final result = await MLService.createProduct(
      name: productName,
      category: category,
      price: price,
      currentStock: initialStock,
      unit: unit,
      productType: productType,
    );

    if (result['status'] == 'success') {
      final createdProductId = result['product_id'];
      products.add(productName);
      if (createdProductId is int && createdProductId > 0) {
        productIds[productName] = createdProductId;
      }
      productCategories[productName] = category;
      productUnits[productName] = unit;
      productPrices[productName] = price;
      if (!categories.contains(category)) {
        categories.add(category);
      }
      notifyListeners();
    }

    return result;
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  static String _defaultUnitFromCategory(String category) {
    if (category.toLowerCase() == 'barang') {
      return 'pcs';
    }
    return 'kg';
  }
}
