import 'package:finalproject/services/ml_service.dart';
import 'package:flutter/material.dart';

class PredictionController extends ChangeNotifier {
  String? selectedRecipe;
  int productionQuantity = 0;
  bool isCalculated = false;
  bool isLoading = true;
  bool isSubmitting = false;

  List<Map<String, dynamic>> recipes = [];
  Map<String, Map<String, dynamic>> recipeIngredients = {};
  Map<String, bool> ingredientSelections = {};

  final Map<String, double> currentStock = {
    'Tepung Terigu 1kg': 45000,
    'Telur 1kg': 12,
    'Gula Pasir 1kg': 28000,
    'Susu Bubuk': 8000,
    'Cokelat Bubuk 250gr': 22000,
    'Mentega 500gr': 15000,
    'Keju Parut 250gr': 3000,
    'Baking Powder': 60000,
  };
  final Map<String, int> productIds = {};
  final Map<String, String> productUnits = {};

  static const double eggGramPerButir = 50;

  Future<String?> loadRecipes() async {
    isLoading = true;
    notifyListeners();

    try {
      final fetchedRecipes = await MLService.getRecipes();
      final fetchedProducts = await MLService.getProducts();
      recipes = fetchedRecipes;
      recipeIngredients = {};

      for (final recipe in recipes) {
        final recipeName = recipe['recipe_name'] as String?;
        if (recipeName == null) continue;

        recipeIngredients[recipeName] = {};

        if (recipe['ingredients'] != null) {
          for (final ingredient in recipe['ingredients']) {
            recipeIngredients[recipeName]![ingredient['product_name']] = {
              'quantity': ingredient['quantity_needed'],
              'unit': ingredient['unit'],
            };
          }
        }
      }

      _applyProductStocks(fetchedProducts);
      _initializeIngredientSelections();

      return null;
    } catch (e) {
      return 'Gagal memuat resep: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStock() async {
    try {
      final fetchedProducts = await MLService.getProducts();
      _applyProductStocks(fetchedProducts);
    } catch (_) {
      // Ignore refresh errors; keep existing stock
    } finally {
      notifyListeners();
    }
  }

  void _applyProductStocks(List<Map<String, dynamic>> products) {
    if (products.isEmpty) return;

    currentStock.clear();
    productIds.clear();
    productUnits.clear();

    for (final product in products) {
      final name =
          (product['name'] ?? product['product_name'] ?? '').toString();
      if (name.isEmpty) continue;

      final id = product['id'] ?? 0;
      final unit = (product['unit'] ?? '').toString();
      final stockRaw = product['current_stock'] ?? 0;
      final stock = stockRaw is num ? stockRaw.toDouble() : 0.0;

      currentStock[name] = stock;
      if (id is int) {
        productIds[name] = id;
      }
      if (unit.isNotEmpty) {
        productUnits[name] = unit;
      }
    }
  }

  void setSelectedRecipe(String? value) {
    selectedRecipe = value;
    isCalculated = false;
    _initializeIngredientSelections();
    notifyListeners();
  }

  void setProductionQuantity(String value) {
    productionQuantity = int.tryParse(value) ?? 0;
    isCalculated = false;
    notifyListeners();
  }

  bool get canCalculate => selectedRecipe != null && productionQuantity > 0;

  void calculate() {
    isCalculated = true;
    notifyListeners();
  }

  void reset() {
    selectedRecipe = null;
    productionQuantity = 0;
    isCalculated = false;
    ingredientSelections = {};
    notifyListeners();
  }

  void setIngredientSelection(String ingredient, bool isSelected) {
    ingredientSelections[ingredient] = isSelected;
    notifyListeners();
  }

  bool isIngredientSelected(String ingredient) {
    return ingredientSelections[ingredient] ?? true;
  }

  void _initializeIngredientSelections() {
    if (selectedRecipe == null) {
      ingredientSelections = {};
      return;
    }

    final ingredients = recipeIngredients[selectedRecipe] ?? {};
    ingredientSelections = {
      for (final ingredient in ingredients.keys) ingredient: true,
    };
  }

  Map<String, double> get requiredIngredients {
    if (selectedRecipe == null || productionQuantity == 0) {
      return {};
    }

    final ingredients = recipeIngredients[selectedRecipe] ?? {};
    final required = <String, double>{};

    ingredients.forEach((productName, details) {
      if (!isIngredientSelected(productName)) return;
      final quantity = (details['quantity'] as num).toDouble();
      required[productName] = quantity * productionQuantity;
    });

    return required;
  }

  Map<String, double> get insufficientStock {
    final required = requiredIngredients;
    final insufficient = <String, double>{};

    required.forEach((ingredient, neededAmount) {
      final requiredInStockUnit = _convertToStockUnit(
        ingredient: ingredient,
        amount: neededAmount,
        fromUnit: getIngredientUnit(ingredient),
      );
      final available = getCurrentStock(ingredient);
      if (available < requiredInStockUnit) {
        insufficient[ingredient] = requiredInStockUnit - available;
      }
    });

    return insufficient;
  }

  bool get isStockSufficient => insufficientStock.isEmpty;

  String getIngredientUnit(String ingredient) {
    if (selectedRecipe == null) return 'gr';
    final recipeIngs = recipeIngredients[selectedRecipe];
    if (recipeIngs == null) return 'gr';
    final ingData = recipeIngs[ingredient];
    if (ingData == null) return 'gr';
    return ingData['unit'] as String? ?? 'gr';
  }

  String getStockUnit(String ingredient) {
    final key = _matchingProductName(ingredient);
    final unit = key == null ? productUnits[ingredient] : productUnits[key];
    if (unit != null && unit.isNotEmpty) return _normalizeUnit(unit);
    return 'kg';
  }

  double getCurrentStock(String ingredient) {
    final key = _matchingProductName(ingredient);
    return key == null ? currentStock[ingredient] ?? 0 : currentStock[key] ?? 0;
  }

  int? getProductId(String ingredient) {
    final key = _matchingProductName(ingredient);
    return key == null ? productIds[ingredient] : productIds[key];
  }

  double toGram({required double amount, required String unit}) {
    final normalized = _normalizeUnit(unit);
    if (normalized == 'gr') return amount;
    if (normalized == 'kg') return amount * 1000;
    if (normalized == 'ml') return amount;
    if (normalized == 'l') return amount * 1000;
    if (normalized == 'butir') return amount * eggGramPerButir;
    return amount;
  }

  double getRequiredInStockUnit(String ingredient) {
    final required = requiredIngredients[ingredient] ?? 0;
    return _convertToStockUnit(
      ingredient: ingredient,
      amount: required,
      fromUnit: getIngredientUnit(ingredient),
    );
  }

  Color getStatusColor(String ingredient) {
    final required = _convertToStockUnit(
      ingredient: ingredient,
      amount: requiredIngredients[ingredient] ?? 0,
      fromUnit: getIngredientUnit(ingredient),
    );
    final available = getCurrentStock(ingredient);
    return available >= required
        ? const Color(0xFF10B981)
        : const Color(0xFFDC2626);
  }

  String cleanIngredientName(String ingredient) {
    return ingredient
        .replaceAll(
          RegExp(
            r'\s+\d+([,.]\d+)?\s*(kg|kilogram|g|gr|gram|ml|l|liter|ltr|butir|pcs)\b',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
  }

  String formatQuantity(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String formatStockQuantity(String ingredient, double value) {
    final unit = getStockUnit(ingredient);
    if (unit == 'kg' && value > 0 && value < 1) {
      return '${formatQuantity(value * 1000)} gr';
    }
    if (unit == 'l' && value > 0 && value < 1) {
      return '${formatQuantity(value * 1000)} ml';
    }
    return '${formatQuantity(value)} $unit';
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
      return 'butir';
    }
    return normalized;
  }

  double _convertToStockUnit({
    required String ingredient,
    required double amount,
    required String fromUnit,
  }) {
    final stockUnit = _normalizeUnit(getStockUnit(ingredient));
    final unit = _normalizeUnit(fromUnit);

    if (unit == stockUnit) return amount;

    if (unit == 'gr' && stockUnit == 'kg') return amount / 1000;
    if (unit == 'kg' && stockUnit == 'gr') return amount * 1000;

    if (unit == 'butir' && stockUnit == 'kg') {
      return (amount * eggGramPerButir) / 1000;
    }
    if (unit == 'butir' && stockUnit == 'gr') {
      return amount * eggGramPerButir;
    }
    if (unit == 'ml' && stockUnit == 'kg') return amount / 1000;
    if (unit == 'l' && stockUnit == 'kg') return amount;
    if (unit == 'kg' && stockUnit == 'ml') return amount * 1000;
    if (unit == 'kg' && stockUnit == 'l') return amount;
    if (unit == 'ml' && stockUnit == 'gr') return amount;
    if (unit == 'gr' && stockUnit == 'ml') return amount;
    if (unit == 'l' && stockUnit == 'ml') return amount * 1000;
    if (unit == 'ml' && stockUnit == 'l') return amount / 1000;
    if (unit == 'kg' && stockUnit == 'butir') {
      return (amount * 1000) / eggGramPerButir;
    }
    if (unit == 'gr' && stockUnit == 'butir') {
      return amount / eggGramPerButir;
    }

    return amount;
  }

  String _ingredientKey(String value) {
    return cleanIngredientName(
      value,
    ).toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _matchingProductName(String ingredient) {
    if (currentStock.containsKey(ingredient)) return ingredient;

    final target = _ingredientKey(ingredient);
    for (final name in currentStock.keys) {
      if (_ingredientKey(name) == target) return name;
    }

    return null;
  }

  Map<String, double> get stockUsage {
    final required = requiredIngredients;
    final usage = <String, double>{};

    required.forEach((ingredient, neededAmount) {
      if (!isIngredientSelected(ingredient)) return;
      final unit = getIngredientUnit(ingredient);
      usage[ingredient] = _convertToStockUnit(
        ingredient: ingredient,
        amount: neededAmount,
        fromUnit: unit,
      );
    });

    return usage;
  }

  String buildEstimatedNeedsText() {
    final usage = stockUsage;
    if (usage.isEmpty) return 'Belum tersedia';

    return usage.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
          final name = cleanIngredientName(entry.key);
          final amount = formatStockQuantity(entry.key, entry.value);
          return '$name: $amount';
        })
        .join(', ');
  }

  Future<Map<String, dynamic>> submitProduction() async {
    if (isSubmitting) {
      return {
        'status': 'error',
        'message': 'Permintaan sedang diproses, mohon tunggu',
      };
    }

    isSubmitting = true;
    notifyListeners();

    try {
      if (selectedRecipe == null || !isCalculated) {
        return {
          'status': 'error',
          'message': 'Hitung kebutuhan terlebih dahulu',
        };
      }

      await refreshStock();
      if (insufficientStock.isNotEmpty) {
        return {
          'status': 'error',
          'message': 'Stok masih kurang, silakan update stok dulu',
        };
      }

      final usage = stockUsage;
      if (usage.isEmpty) {
        return {'status': 'error', 'message': 'Tidak ada bahan yang dipilih'};
      }

      final items =
          usage.entries.where((entry) => entry.value > 0).map((entry) {
            final ingredient = entry.key;
            final quantity = entry.value;
            return {
              'product_id': getProductId(ingredient),
              'product_name': ingredient,
              'quantity': quantity,
              'unit': getStockUnit(ingredient),
            };
          }).toList();

      final result = await MLService.consumeStock(
        items: items,
        recipeName: selectedRecipe,
        productionQuantity: productionQuantity,
      );

      if (result['status'] == 'success') {
        // Simpan hasil prediksi ke database agar laporan total prediksi ter-update.
        await MLService.savePrediction(
          productName: selectedRecipe ?? 'Produk',
          category: 'Produk',
          unitPrice: 0,
          predictionDate: DateTime.now().toIso8601String().split('T').first,
          predictedQuantity: productionQuantity,
          estimatedNeeds: buildEstimatedNeedsText(),
        );

        for (final entry in usage.entries) {
          final ingredient = entry.key;
          final quantity = entry.value;
          final key = _matchingProductName(ingredient) ?? ingredient;
          final available = currentStock[key] ?? 0;
          currentStock[key] = (available - quantity).clamp(0, double.infinity);
        }
        await refreshStock();
      }

      return result;
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal submit: $e'};
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
