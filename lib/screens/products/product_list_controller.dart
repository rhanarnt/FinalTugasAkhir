import 'package:finalproject/models/product_model.dart';
import 'package:finalproject/services/ml_service.dart';
import 'package:finalproject/utils/stock_status.dart';
import 'package:flutter/material.dart';

class ProductListController extends ChangeNotifier {
  String selectedFilter = 'semua';
  String searchQuery = '';
  bool isLoading = true;

  List<Product> products = [];

  static const Map<String, String> datasetUnits = {
    'Baking Powder 45gr': 'gr',
    'Baking Powder': 'gr',
    'Cokelat Bubuk 250gr': 'gr',
    'Gula Pasir 1kg': 'kg',
    'Keju Parut 250gr': 'gr',
    'Mentega 500gr': 'gr',
    'Susu Bubuk 27gr': 'gr',
    'Susu Bubuk': 'gr',
    'Telur 1kg': 'kg',
    'Tepung Terigu 1kg': 'kg',
  };

  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      final fetchedProducts = await MLService.getProducts();

      products =
          fetchedProducts.map((p) {
            final stock = StockStatusUtils.parseStock(p['current_stock']);
            final minStock = StockStatusUtils.parseStock(p['min_stock']);
            final category = p['category'] ?? '';
            final name = p['name'] ?? '';
            final unit =
                p['unit'] ??
                datasetUnits[name] ??
                (category.toString().toLowerCase() == 'barang' ? 'pcs' : 'kg');
            return Product(
              id: p['id'] ?? 0,
              name: name,
              category: category,
              price: p['price'] ?? 0,
              stock: stock,
              minStock: minStock,
              unit: unit,
              status: StockStatusUtils.statusFromStock(
                stock,
                minStock: minStock,
              ),
            );
          }).toList();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Product> get filteredProducts {
    var result = products;

    if (selectedFilter != 'semua') {
      result = result.where((p) => p.status == selectedFilter).toList();
    }

    if (searchQuery.isNotEmpty) {
      result =
          result
              .where(
                (p) =>
                    p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                    p.category.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    return result;
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setFilter(String value) {
    selectedFilter = value;
    notifyListeners();
  }

  int get maxStock {
    return maxStockValue.ceil().clamp(1, double.infinity).toInt();
  }

  double get maxStockValue {
    if (products.isEmpty) return 1;
    final maxValue = products.fold<double>(
      0,
      (max, p) => p.stock > max ? p.stock : max,
    );
    return maxValue <= 0 ? 1 : maxValue;
  }

  Color getStatusColor(String status) {
    return StockStatusUtils.color(status);
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Tepung':
        return Icons.grain;
      case 'Telur':
        return Icons.circle;
      case 'Gula':
        return Icons.blur_circular;
      case 'Susu':
        return Icons.local_drink;
      case 'Cokelat':
        return Icons.square_rounded;
      case 'Mentega':
        return Icons.spa;
      case 'Keju':
        return Icons.lunch_dining;
      case 'Bahan Tambahan':
        return Icons.miscellaneous_services;
      default:
        return Icons.shopping_bag;
    }
  }

  String formatPrice(int price) => 'Rp ${(price ~/ 1000)}K';

  String formatStock(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value
        .toStringAsFixed(3)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String formatStockDisplay(double value, String rawUnit) {
    return formatQuantityWithUnit(value, rawUnit);
  }

  String minimumStockUnit(Product product) {
    return _displayUnitLabel(product.unit);
  }

  String displayUnit(Product product) {
    return _displayUnitLabel(product.unit);
  }

  String formatQuantityWithUnit(double amount, String rawUnit) {
    final displayUnit = _displayUnitLabel(rawUnit);
    return '${formatStock(amount)} $displayUnit';
  }

  String _displayUnitLabel(String unit) {
    final normalized = _normalizeUnit(unit);
    if (normalized == 'pcs' || normalized == 'butir') return 'pcs';
    if (normalized == 'gr') return 'kg';
    if (normalized == 'ml') return 'L';
    if (normalized == 'l') return 'L';
    if (normalized == 'kg') return 'kg';
    return unit.trim().isEmpty ? 'kg' : unit.trim();
  }

  String _normalizeUnit(String unit) {
    final normalized = unit.trim().toLowerCase();
    if (['g', 'gr', 'gram', 'grams'].contains(normalized)) return 'gr';
    if (['kg', 'kilogram', 'kilograms'].contains(normalized)) return 'kg';
    if (['ml', 'mili', 'mililiter', 'milliliter'].contains(normalized)) {
      return 'ml';
    }
    if (['l', 'lt', 'ltr', 'liter', 'litre'].contains(normalized)) return 'l';
    if (['butir', 'pcs', 'piece', 'pieces'].contains(normalized)) {
      return 'pcs';
    }
    return normalized;
  }

  Future<String?> updateProduct({
    required Product product,
    required String name,
    required String category,
    required int price,
    required double stock,
    required double minStock,
    required String unit,
  }) async {
    final result = await MLService.updateProduct(
      productId: product.id,
      name: name,
      category: category,
      price: price,
      currentStock: stock,
      minStock: minStock,
      unit: unit,
    );

    if (result['status'] != 'success') {
      return result['message']?.toString() ?? 'Gagal mengubah produk';
    }

    await loadProducts();
    return null;
  }

  String getStatusLabel(String status) {
    return StockStatusUtils.label(status, withIcon: true);
  }

  String capitalize(String text) =>
      '${text[0].toUpperCase()}${text.substring(1)}';
}
