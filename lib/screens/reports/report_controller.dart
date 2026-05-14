import 'dart:async';

import 'package:finalproject/services/ml_service.dart';
import 'package:finalproject/utils/stock_status.dart';
import 'package:flutter/material.dart';

class ReportController extends ChangeNotifier {
  bool isLoading = true;
  String? errorMessage;

  final List<Map<String, dynamic>> stockItems = [];
  final List<Map<String, dynamic>> stockHistory = [];
  final List<Map<String, dynamic>> predictionItems = [];
  final List<Map<String, dynamic>> criticalItems = [];
  final List<Map<String, dynamic>> usageSummary = [];
  final List<double> demandTrend = [];

  int totalProduk = 0;
  int totalBahan = 0;
  int totalPrediksi = 0;
  int totalKritis = 0;

  int _productCount = 0;

  Timer? _refreshTimer;

  /// Load semua data laporan dari API.
  Future<void> loadReports({bool showLoading = true}) async {
    if (showLoading) {
      isLoading = true;
      notifyListeners();
    }

    try {
      errorMessage = null;

      final results = await Future.wait([
        MLService.getReportStock(),
        MLService.getReportStockIn(),
        MLService.getReportPredictions(),
        MLService.getProducts(),
        MLService.getDashboardSummary(),
      ]);

      final stockResponse = results[0] as Map<String, dynamic>;
      final stockInResponse = results[1] as Map<String, dynamic>;
      final predictionResponse = results[2] as Map<String, dynamic>;
      final productsResponse = results[3];
      final dashboardSummary = results[4] as Map<String, dynamic>;

      if (stockResponse['status'] != true) {
        errorMessage = stockResponse['message']?.toString();
      } else {
        _applyStockItems(stockResponse['data']);
      }

      if (stockInResponse['status'] != true) {
        errorMessage ??= stockInResponse['message']?.toString();
      } else {
        _applyStockHistory(stockInResponse['data']);
      }

      if (predictionResponse['status'] != true) {
        errorMessage ??= predictionResponse['message']?.toString();
      } else {
        _applyPredictions(predictionResponse['data']);
      }

      if (productsResponse is List) {
        _productCount = productsResponse.length;
        _applyCriticalProducts(productsResponse);
      } else {
        _productCount = 0;
        criticalItems.clear();
      }

      if (dashboardSummary['status'] != true) {
        errorMessage ??= dashboardSummary['message']?.toString();
        usageSummary.clear();
      } else {
        _applyUsageSummary(dashboardSummary['penggunaan_bahan']);
      }

      _rebuildSummary();
      _rebuildDemandTrend();
    } catch (e) {
      errorMessage = 'Gagal memuat laporan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh otomatis agar laporan selalu realtime.
  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => loadReports(showLoading: false),
    );
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _applyStockItems(dynamic data) {
    stockItems.clear();
    if (data is! List) return;
    for (final item in data) {
      stockItems.add({
        'name': item['nama_bahan']?.toString() ?? '-',
        'stock': _toDouble(item['stok']),
        'min_stock': _toDouble(item['stok_minimum']),
        'status': item['status']?.toString() ?? 'Aman',
        'unit': item['unit']?.toString() ?? 'kg',
      });
    }
  }

  void _applyStockHistory(dynamic data) {
    stockHistory.clear();
    if (data is! List) return;
    for (final item in data) {
      stockHistory.add({
        'date': _parseDate(item['tanggal']),
        'name': item['nama_bahan']?.toString() ?? '-',
        'amount': _toDouble(item['jumlah']),
        'unit': item['unit']?.toString() ?? 'kg',
      });
    }
    stockHistory.sort((a, b) {
      final aDate = a['date'] as DateTime;
      final bDate = b['date'] as DateTime;
      return bDate.compareTo(aDate);
    });
  }

  void _applyPredictions(dynamic data) {
    predictionItems.clear();
    if (data is! List) return;
    for (final item in data) {
      final needsValue = item['estimasi_kebutuhan_bahan'];
      final needsText =
          needsValue == null || needsValue.toString().isEmpty
              ? 'Belum tersedia'
              : needsValue.toString();
      predictionItems.add({
        'product': item['nama_produk']?.toString() ?? '-',
        'prediction': _toDouble(item['hasil_prediksi']),
        'needs': needsText,
        'date': _parseDate(item['tanggal_prediksi']),
      });
    }
  }

  void _applyCriticalProducts(List<dynamic> products) {
    criticalItems.clear();

    for (final item in products) {
      if (item is! Map) continue;

      final stock = StockStatusUtils.parseStock(item['current_stock']);
      final status = StockStatusUtils.statusFromStock(stock);
      if (status != StockStatusUtils.statusKritis) continue;

      final category = item['category']?.toString().toLowerCase() ?? '';
      final unit =
          item['unit']?.toString() ?? (category == 'barang' ? 'pcs' : 'kg');
      criticalItems.add({
        'name': item['name']?.toString() ?? '-',
        'stock': stock,
        'status': StockStatusUtils.label(status),
        'unit': unit,
      });
    }

    criticalItems.sort(
      (a, b) => a['name'].toString().compareTo(b['name'].toString()),
    );
  }

  void _applyUsageSummary(dynamic data) {
    usageSummary.clear();
    if (data is! List) return;

    for (final item in data) {
      if (item is! Map) continue;

      final label = item['nama_bahan']?.toString() ?? '-';
      final total = _toDouble(item['total_digunakan']);
      final unit = item['satuan']?.toString() ?? 'kg';
      if (total <= 0) continue;

      usageSummary.add({'label': label, 'value': total, 'unit': unit});
    }

    usageSummary.sort(
      (a, b) => (b['value'] as double).compareTo(a['value'] as double),
    );
  }

  void _rebuildSummary() {
    totalBahan = stockItems.length;
    totalProduk = _productCount;
    totalPrediksi = predictionItems.length;
    totalKritis = criticalItems.length;
  }

  void _rebuildDemandTrend() {
    final sorted =
        predictionItems.toList()..sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
        );
    final latestItems =
        sorted.length > 7 ? sorted.skip(sorted.length - 7) : sorted;

    demandTrend
      ..clear()
      ..addAll(latestItems.map((entry) => (entry['prediction'] as double)));
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
