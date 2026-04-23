import 'package:finalproject/models/product_model.dart';
import 'package:finalproject/services/ml_service.dart';
import 'package:flutter/material.dart';

class ProductListController extends ChangeNotifier {
  String selectedFilter = 'semua';
  String searchQuery = '';
  bool isLoading = true;

  List<Product> products = [];

  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      final fetchedProducts = await MLService.getProducts();

      String getStatus(int stock) {
        if (stock == 0) return 'kritis';
        if (stock <= 5) return 'rendah';
        return 'tersedia';
      }

      products =
          fetchedProducts.map((p) {
            final stock = p['current_stock'] ?? 0;
            final category = p['category'] ?? '';
            final unit =
                p['unit'] ??
                (category.toString().toLowerCase() == 'barang' ? 'pcs' : 'kg');
            return Product(
              id: p['id'] ?? 0,
              name: p['name'] ?? '',
              category: category,
              price: p['price'] ?? 0,
              stock: stock,
              unit: unit,
              status: getStatus(stock),
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
    if (products.isEmpty) return 1;
    return products.fold<int>(0, (max, p) => p.stock > max ? p.stock : max);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'tersedia':
        return const Color(0xFF10B981);
      case 'rendah':
        return const Color(0xFFFB923C);
      case 'kritis':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF9CA3AF);
    }
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

  String getStatusLabel(String status) {
    switch (status) {
      case 'tersedia':
        return '✅ Tersedia';
      case 'rendah':
        return '⚠️ Rendah';
      case 'kritis':
        return '🔴 Kritis';
      default:
        return 'Unknown';
    }
  }

  String capitalize(String text) =>
      '${text[0].toUpperCase()}${text.substring(1)}';
}
