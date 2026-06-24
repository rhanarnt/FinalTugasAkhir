import 'dart:async';
import 'dart:io';

import 'package:finalproject/services/ml_service.dart';
import 'package:finalproject/utils/stock_status.dart';
import 'package:flutter/material.dart';

class ReportController extends ChangeNotifier {
  bool isLoading = true;
  bool isForecastLoading = false;
  String? errorMessage;

  final List<Map<String, dynamic>> stockItems = [];
  final List<Map<String, dynamic>> stockHistory = [];
  final List<Map<String, dynamic>> predictionItems = [];
  final List<Map<String, dynamic>> forecastItems = [];
  final List<Map<String, dynamic>> criticalItems = [];
  final List<Map<String, dynamic>> usageSummary = [];
  final List<double> demandTrend = [];
  final Map<String, List<Map<String, dynamic>>> _recipeIngredients = {};

  int totalProduk = 0;
  int totalBahan = 0;
  int totalPrediksi = 0;
  int totalKritis = 0;

  int forecastDays = 7;

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
        MLService.getRecipes(),
      ]);

      final stockResponse = results[0] as Map<String, dynamic>;
      final stockInResponse = results[1] as Map<String, dynamic>;
      final predictionResponse = results[2] as Map<String, dynamic>;
      final productsResponse = results[3];
      final dashboardSummary = results[4] as Map<String, dynamic>;
      final recipesResponse = results[5];

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

      if (recipesResponse is List) {
        _applyRecipes(recipesResponse);
      } else {
        _recipeIngredients.clear();
      }

      if (dashboardSummary['status'] != true) {
        errorMessage ??= dashboardSummary['message']?.toString();
        usageSummary.clear();
      } else {
        _applyUsageSummary(dashboardSummary['penggunaan_bahan']);
      }

      if (usageSummary.isEmpty) {
        _rebuildUsageSummaryFromPredictions();
      }

      _rebuildSummary();
      _rebuildDemandTrend();
      await loadForecast(showLoading: false);
    } catch (e) {
      errorMessage = 'Gagal memuat laporan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setForecastDays(int days) async {
    if (forecastDays == days) return;

    forecastDays = days;
    await loadForecast();
  }

  Future<void> loadForecast({bool showLoading = true}) async {
    if (showLoading) {
      isForecastLoading = true;
      notifyListeners();
    }

    try {
      final forecastResponse = await MLService.getReportPredictionForecast(
        days: forecastDays,
        months: 1,
        limit: 8,
      );

      if (forecastResponse['status'] != true) {
        forecastItems.clear();
      } else {
        _applyForecasts(forecastResponse['data']);
      }
    } catch (_) {
      forecastItems.clear();
    } finally {
      isForecastLoading = false;
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

  void _applyForecasts(dynamic data) {
    forecastItems.clear();
    if (data is! List) return;

    for (final item in data) {
      if (item is! Map) continue;

      final ingredientsData = item['bahan'];
      final recipeTargetsData = item['target_produksi'];
      final ingredients = <Map<String, dynamic>>[];
      final recipeTargets = <Map<String, dynamic>>[];

      if (ingredientsData is List) {
        for (final ingredient in ingredientsData) {
          if (ingredient is! Map) continue;
          ingredients.add({
            'name': ingredient['nama_bahan']?.toString() ?? '-',
            'quantity': _toDouble(ingredient['jumlah']),
            'unit': ingredient['unit']?.toString() ?? 'kg',
          });
        }
      }

      if (recipeTargetsData is List) {
        for (final target in recipeTargetsData) {
          if (target is! Map) continue;
          recipeTargets.add({
            'recipe_name': target['recipe_name']?.toString() ?? '-',
            'production': _toDouble(target['target_produksi']),
          });
        }
      }

      forecastItems.add({
        'date': _parseDate(item['tanggal_prediksi']),
        'multiplier': _toDouble(item['multiplier']),
        'ingredients': ingredients,
        'recipe_targets': recipeTargets,
        'ingredient_count': _toDouble(item['jumlah_bahan']),
        'total_bahan': _toDouble(item['total_bahan']),
      });
    }
  }

  void _applyCriticalProducts(List<dynamic> products) {
    criticalItems.clear();

    for (final item in products) {
      if (item is! Map) continue;

      final stock = StockStatusUtils.parseStock(item['current_stock']);
      final minStock = StockStatusUtils.parseStock(item['min_stock']);
      final status = StockStatusUtils.statusFromStock(
        stock,
        minStock: minStock,
      );
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

  void _applyRecipes(List<dynamic> recipes) {
    _recipeIngredients.clear();

    for (final recipe in recipes) {
      if (recipe is! Map) continue;

      final recipeName = recipe['recipe_name']?.toString() ?? '';
      if (recipeName.isEmpty) continue;

      final ingredients = recipe['ingredients'];
      if (ingredients is! List) continue;

      _recipeIngredients[_nameKey(recipeName)] =
          ingredients
              .whereType<Map>()
              .map(
                (ingredient) => {
                  'label': ingredient['product_name']?.toString() ?? '-',
                  'value': _toDouble(ingredient['quantity_needed']),
                  'unit': _normalizeUnit(ingredient['unit']?.toString() ?? ''),
                },
              )
              .where(
                (ingredient) =>
                    (ingredient['label'] as String).isNotEmpty &&
                    (ingredient['value'] as double) > 0,
              )
              .toList();
    }
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

  void _rebuildUsageSummaryFromPredictions() {
    final Map<String, Map<String, dynamic>> totals = {};

    for (final item in predictionItems) {
      final needs = item['needs']?.toString() ?? '';
      final ingredients =
          needs.isEmpty || needs == 'Belum tersedia'
              ? _estimateUsageFromRecipe(item)
              : _parseEstimatedNeeds(needs);

      for (final ingredient in ingredients) {
        final label = ingredient['label'] as String;
        final normalizedQuantity = _normalizeUsageQuantity(
          value: ingredient['value'] as double,
          unit: ingredient['unit'] as String,
        );
        final unit = normalizedQuantity['unit'] as String;
        final value = normalizedQuantity['value'] as double;
        if (label.isEmpty || value <= 0) continue;

        final key = '${label.toLowerCase()}|$unit';
        final current = totals[key];
        if (current == null) {
          totals[key] = {'label': label, 'value': value, 'unit': unit};
        } else {
          current['value'] = (current['value'] as double) + value;
        }
      }
    }

    usageSummary
      ..clear()
      ..addAll(totals.values);

    usageSummary.sort(
      (a, b) => (b['value'] as double).compareTo(a['value'] as double),
    );

    if (usageSummary.length > 5) {
      usageSummary.removeRange(5, usageSummary.length);
    }
  }

  List<Map<String, dynamic>> _parseEstimatedNeeds(String text) {
    final entries = <Map<String, dynamic>>[];
    final normalized = text.trim();
    if (normalized.isEmpty || normalized == 'Belum tersedia') return entries;

    for (final part in normalized.split(',')) {
      final separatorIndex = part.indexOf(':');
      if (separatorIndex <= 0) continue;

      final label = part.substring(0, separatorIndex).trim();
      final quantityText = part.substring(separatorIndex + 1).trim();
      final match = RegExp(
        r'^([0-9]+(?:[.,][0-9]+)?)\s*([a-zA-Z]+)?',
      ).firstMatch(quantityText);
      if (match == null) continue;

      final value = _toDouble(match.group(1)?.replaceAll(',', '.'));
      final unit = _normalizeUnit(match.group(2) ?? 'unit');
      entries.add({'label': label, 'value': value, 'unit': unit});
    }

    return entries;
  }

  List<Map<String, dynamic>> _estimateUsageFromRecipe(
    Map<String, dynamic> prediction,
  ) {
    final productName = prediction['product']?.toString() ?? '';
    final ingredients = _recipeIngredients[_nameKey(productName)];
    if (ingredients == null || ingredients.isEmpty) return [];

    final predictedQuantity = _toDouble(prediction['prediction']);
    if (predictedQuantity <= 0) return [];

    return ingredients.map((ingredient) {
      return {
        'label': ingredient['label'],
        'value': (ingredient['value'] as double) * predictedQuantity,
        'unit': ingredient['unit'],
      };
    }).toList();
  }

  String _normalizeUnit(String unit) {
    final normalized = unit.trim().toLowerCase();
    if (['g', 'gr', 'gram', 'grams'].contains(normalized)) return 'gr';
    if (['kg', 'kilogram', 'kilograms'].contains(normalized)) return 'kg';
    if (['ml', 'mili', 'mililiter', 'milliliter'].contains(normalized)) {
      return 'ml';
    }
    if (['l', 'lt', 'ltr', 'liter', 'litre'].contains(normalized)) return 'l';
    if (['pcs', 'piece', 'pieces'].contains(normalized)) return 'pcs';
    if (['butir'].contains(normalized)) return 'butir';
    return normalized.isEmpty ? 'unit' : normalized;
  }

  Map<String, dynamic> _normalizeUsageQuantity({
    required double value,
    required String unit,
  }) {
    switch (_normalizeUnit(unit)) {
      case 'gr':
        return {'value': value / 1000, 'unit': 'kg'};
      case 'ml':
        return {'value': value / 1000, 'unit': 'l'};
      default:
        return {'value': value, 'unit': _normalizeUnit(unit)};
    }
  }

  String _nameKey(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(
          RegExp(
            r'\s+\d+([,.]\d+)?\s*(kg|kilogram|g|gr|gram|ml|l|liter|ltr|butir|pcs)\b',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
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
      final text = value.trim();
      if (text.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);

      final parsed = DateTime.tryParse(text);
      if (parsed != null) return parsed;

      try {
        return HttpDate.parse(text).toLocal();
      } catch (_) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
