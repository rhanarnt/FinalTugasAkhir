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
        MLService.getReportCritical(),
      ]);

      final bahanDigunakan = results[0] as Map<String, dynamic>;
      final summary = results[1] as Map<String, dynamic>;
      final products = results[2] as List;
      final critical = results[3] as Map<String, dynamic>;

      _applyBahanDigunakanHariIni(bahanDigunakan);

      if (summary['status'] == true) {
        _applyPenggunaanBahan(summary['penggunaan_bahan']);
      } else {
        errorMessage = summary['message']?.toString();
        _applyDummyPenggunaan();
      }

      totalProduk = products.length;

      if (critical['status'] == true) {
        _applyLowStockItems(critical['data']);
      } else {
        _applyDummyLowStock();
      }
    } catch (e) {
      errorMessage = 'Gagal memuat dashboard: $e';
      bahanDigunakanError = 'Gagal memuat bahan digunakan hari ini';
      _resetBahanDigunakanHariIni();
      _applyDummyPenggunaan();
      _applyDummyLowStock();
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

  void _applyLowStockItems(dynamic data) {
    lowStockItems.clear();
    if (data is! List || data.isEmpty) {
      _applyDummyLowStock();
      return;
    }

    for (final item in data) {
      final stockValue = StockStatusUtils.parseStock(item['stok']);
      final statusKey = StockStatusUtils.statusFromStock(stockValue);
      final unit = item['unit'] ?? 'kg';
      final stockLabel = item['stok']?.toString() ?? '0';
      lowStockItems.add({
        'name': item['nama_bahan']?.toString() ?? '-',
        'stock': '$stockLabel $unit',
        'status': StockStatusUtils.label(statusKey),
        'statusColor': StockStatusUtils.color(statusKey),
      });
    }
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

  void _applyDummyLowStock() {
    lowStockItems
      ..clear()
      ..addAll([
        {
          'name': 'Tepung Terigu',
          'stock': '5 kg',
          'status': StockStatusUtils.label(StockStatusUtils.statusFromStock(5)),
          'statusColor': StockStatusUtils.color(
            StockStatusUtils.statusFromStock(5),
          ),
        },
        {
          'name': 'Gula Pasir',
          'stock': '8 kg',
          'status': StockStatusUtils.label(StockStatusUtils.statusFromStock(8)),
          'statusColor': StockStatusUtils.color(
            StockStatusUtils.statusFromStock(8),
          ),
        },
        {
          'name': 'Mentega',
          'stock': '3 kg',
          'status': StockStatusUtils.label(StockStatusUtils.statusFromStock(3)),
          'statusColor': StockStatusUtils.color(
            StockStatusUtils.statusFromStock(3),
          ),
        },
      ]);
  }
}
