import 'package:finalproject/services/ml_service.dart';
import 'package:finalproject/utils/stock_status.dart';
import 'package:flutter/material.dart';

class DashboardController extends ChangeNotifier {
  int selectedIndex = 0;

  bool isLoading = true;
  bool isBahanDigunakanLoading = true;
  String? errorMessage;
  String? bahanDigunakanError;

  double totalBahanDigunakanHariIni = 0;
  String bahanDigunakanSatuan = 'kg';
  String bahanDigunakanKeterangan = 'total penggunaan hari ini';
  int totalProduk = 0;

  final List<Map<String, dynamic>> penggunaanBahan = [];
  final List<Map<String, dynamic>> lowStockItems = [];

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> loadDashboard({bool showLoading = true}) async {
    if (showLoading) {
      isLoading = true;
      isBahanDigunakanLoading = true;
      notifyListeners();
    }

    try {
      errorMessage = null;
      bahanDigunakanError = null;

      final results = await Future.wait([
        MLService.getBahanDigunakanHariIni(),
        MLService.getDashboardSummary(),
        MLService.getProducts(),
      ]);

      final bahanDigunakan = results[0] as Map<String, dynamic>;
      final summary = results[1] as Map<String, dynamic>;
      final products = results[2] as List;

      _applyBahanDigunakanHariIni(bahanDigunakan);

      if (summary['status'] == true) {
        _applyPenggunaanBahan(summary['penggunaan_bahan']);
      } else {
        errorMessage = summary['message']?.toString();
        _applyDummyPenggunaan();
      }

      totalProduk = products.length;
      _applyLowStockProducts(products);
    } catch (e) {
      errorMessage = 'Gagal memuat dashboard: $e';
      bahanDigunakanError = 'Gagal memuat bahan digunakan hari ini';
      _resetBahanDigunakanHariIni();
      _applyDummyPenggunaan();
      lowStockItems.clear();
    } finally {
      isLoading = false;
      isBahanDigunakanLoading = false;
      notifyListeners();
    }
  }

  void _applyBahanDigunakanHariIni(Map<String, dynamic> data) {
    if (data['status'] == false) {
      bahanDigunakanError = data['message']?.toString();
      _resetBahanDigunakanHariIni();
      return;
    }

    totalBahanDigunakanHariIni = (data['total'] as num?)?.toDouble() ?? 0;
    bahanDigunakanSatuan = data['satuan']?.toString() ?? 'kg';
    bahanDigunakanKeterangan =
        data['keterangan']?.toString() ?? 'total penggunaan hari ini';
  }

  void _resetBahanDigunakanHariIni() {
    totalBahanDigunakanHariIni = 0;
    bahanDigunakanSatuan = 'kg';
    bahanDigunakanKeterangan = 'total penggunaan hari ini';
  }

  void _applyPenggunaanBahan(dynamic data) {
    penggunaanBahan.clear();
    if (data is! List || data.isEmpty) {
      _applyDummyPenggunaan();
      return;
    }
    for (final item in data) {
      penggunaanBahan.add({
        'name': item['nama_bahan']?.toString() ?? '-',
        'total': (item['total_digunakan'] as num?)?.toDouble() ?? 0,
        'unit': item['satuan']?.toString() ?? 'kg',
      });
    }
  }

  void _applyLowStockProducts(List<dynamic> products) {
    lowStockItems.clear();

    for (final item in products) {
      if (item is! Map) continue;

      final stockValue = StockStatusUtils.parseStock(item['current_stock']);
      final statusKey = StockStatusUtils.statusFromStock(stockValue);
      if (statusKey != StockStatusUtils.statusKritis) continue;

      final category = item['category']?.toString().toLowerCase() ?? '';
      final unit =
          item['unit']?.toString() ?? (category == 'barang' ? 'pcs' : 'kg');
      lowStockItems.add({
        'name': item['name']?.toString() ?? '-',
        'stock': '${_formatStock(stockValue)} $unit',
        'statusKey': statusKey,
        'status': StockStatusUtils.label(statusKey),
        'statusColor': StockStatusUtils.color(statusKey),
      });
    }

    lowStockItems.sort(
      (a, b) => a['name'].toString().compareTo(b['name'].toString()),
    );
  }

  void _applyDummyPenggunaan() {
    penggunaanBahan
      ..clear()
      ..addAll([
        {'name': 'Tepung Terigu', 'total': 120.0, 'unit': 'kg'},
        {'name': 'Gula', 'total': 80.0, 'unit': 'kg'},
        {'name': 'Mentega', 'total': 45.0, 'unit': 'kg'},
        {'name': 'Telur', 'total': 30.0, 'unit': 'kg'},
        {'name': 'Coklat Bubuk', 'total': 20.0, 'unit': 'kg'},
      ]);
  }

  String _formatStock(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}
