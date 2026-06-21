import 'package:finalproject/services/ml_service.dart';
import 'package:flutter/material.dart';

class PredictionController extends ChangeNotifier {
  String? selectedRecipe;
  int productionQuantity = 0;
  bool isCalculated = false;
  bool isLoading = true;
  bool isSubmitting = false;
  bool isPredicting = false;
  int? predictedDemand;
  double? predictionRawValue;
  double? predictionR2;
  double? predictionMae;
  double? predictionRmse;
  String? predictionModelProduct;

  List<Map<String, dynamic>> recipes = [];
  Map<String, Map<String, dynamic>> recipeIngredients = {};
  Map<String, bool> ingredientSelections = {};

  final Map<String, double> currentStock = {};
  final Map<String, int> productIds = {};
  final Map<String, String> productUnits = {};
  final Map<String, String> productCategories = {};
  final Map<String, int> productPrices = {};

  static const double eggGramPerButir = 50;
  static const Map<String, double> datasetPackageSizes = {
    'Baking Powder 45gr': 45,
    'Cokelat Bubuk 250gr': 250,
    'Gula Pasir 1kg': 1000,
    'Keju Parut 250gr': 250,
    'Mentega 500gr': 500,
    'Susu Bubuk 27gr': 27,
    'Susu Bubuk': 27,
    'Telur 1kg': 1000,
    'Tepung Terigu 1kg': 1000,
  };
  static const Map<String, String> datasetCategories = {
    'Baking Powder 45gr': 'Bahan Tambahan',
    'Cokelat Bubuk 250gr': 'Cokelat',
    'Gula Pasir 1kg': 'Gula',
    'Keju Parut 250gr': 'Keju',
    'Mentega 500gr': 'Mentega',
    'Susu Bubuk 27gr': 'Susu',
    'Telur 1kg': 'Telur',
    'Tepung Terigu 1kg': 'Tepung',
  };
  static const Map<String, int> datasetMedianPrices = {
    'Baking Powder 45gr': 8180,
    'Cokelat Bubuk 250gr': 21036,
    'Gula Pasir 1kg': 14608,
    'Keju Parut 250gr': 23373,
    'Mentega 500gr': 17529,
    'Susu Bubuk 27gr': 17529,
    'Telur 1kg': 26878,
    'Tepung Terigu 1kg': 11687,
  };

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
    productCategories.clear();
    productPrices.clear();

    for (final product in products) {
      final name =
          (product['name'] ?? product['product_name'] ?? '').toString();
      if (name.isEmpty) continue;

      final id = _toInt(product['id']);
      final unit = (product['unit'] ?? '').toString();
      final stock = _toDouble(product['current_stock'] ?? product['stock']);
      final category = (product['category'] ?? '').toString();
      final price = _toInt(product['price'] ?? product['unit_price']) ?? 0;

      currentStock[name] = stock;
      if (id != null) {
        productIds[name] = id;
      }
      if (unit.isNotEmpty) {
        productUnits[name] = unit;
      }
      if (category.isNotEmpty) {
        productCategories[name] = category;
      }
      productPrices[name] = price;
    }
  }

  void setSelectedRecipe(String? value) {
    selectedRecipe = value;
    isCalculated = false;
    _clearPredictionResult();
    _initializeIngredientSelections();
    notifyListeners();
  }

  void setProductionQuantity(String value) {
    productionQuantity = int.tryParse(value) ?? 0;
    isCalculated = false;
    _clearPredictionResult();
    notifyListeners();
  }

  bool get canCalculate => selectedRecipe != null && !isPredicting;

  Future<String?> calculate() async {
    if (selectedRecipe == null) {
      return 'Pilih produk terlebih dahulu';
    }

    isPredicting = true;
    isCalculated = false;
    _clearPredictionResult();
    notifyListeners();

    try {
      await refreshStock();

      final recipeIngredient = _primaryIngredientForPrediction();
      if (recipeIngredient == null) {
        return 'Resep ini belum memiliki bahan yang cocok dengan dataset model';
      }
      final modelProduct = _datasetProductName(recipeIngredient)!;

      final manualQuantity = productionQuantity;
      final plannedQuantity = manualQuantity > 0 ? manualQuantity : 1;
      final result = await MLService.simplePrediksi(
        productName: modelProduct,
        category: _datasetCategory(modelProduct),
        unitPrice: _datasetPrice(modelProduct),
        plannedQuantity: plannedQuantity,
      );

      if (result['status'] != 'success') {
        return result['message']?.toString() ?? 'Prediksi gagal diproses';
      }

      final prediction = result['prediksi'] as Map<String, dynamic>? ?? {};
      final accuracy = result['model_accuracy'] as Map<String, dynamic>? ?? {};
      final rawValue = _toDouble(prediction['nilai_raw']);
      final demand =
          _toInt(prediction['jumlah_unit']) ??
          rawValue.round().clamp(1, 999999).toInt();
      final demandInStockUnit = _datasetDemandToStockUnit(
        ingredient: recipeIngredient,
        demand: demand.toDouble(),
      );
      final perUnitNeed = _quantityPerUnitInStockUnit(recipeIngredient);
      final modelProduction =
          perUnitNeed > 0 ? (demandInStockUnit / perUnitNeed).round() : demand;

      productionQuantity =
          manualQuantity > 0
              ? manualQuantity
              : modelProduction.clamp(1, 999999);
      predictedDemand = manualQuantity > 0 ? manualQuantity : demand;
      predictionRawValue = rawValue;
      predictionR2 = _toDouble(accuracy['r2_score']);
      predictionMae = _toDouble(accuracy['mae']);
      predictionRmse = _toDouble(accuracy['rmse']);
      predictionModelProduct = modelProduct;
      isCalculated = true;

      return null;
    } catch (e) {
      return 'Gagal menjalankan prediksi Random Forest: $e';
    } finally {
      isPredicting = false;
      notifyListeners();
    }
  }

  void reset() {
    selectedRecipe = null;
    productionQuantity = 0;
    isCalculated = false;
    _clearPredictionResult();
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
      final quantity = _toDouble(details['quantity']);
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

  String getProductCategory(String ingredient) {
    final key = _matchingProductName(ingredient);
    return key == null
        ? productCategories[ingredient] ?? 'Bahan Tambahan'
        : productCategories[key] ?? 'Bahan Tambahan';
  }

  int getProductPrice(String ingredient) {
    final key = _matchingProductName(ingredient);
    return key == null
        ? productPrices[ingredient] ?? 0
        : productPrices[key] ?? 0;
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

  String formatQuantityWithUnit(double amount, String unit) {
    final displayUnit = _displayUnitLabel(unit);
    return '${formatQuantity(amount)} $displayUnit';
  }

  String formatStockQuantity(String ingredient, double value) {
    return formatQuantityWithUnit(value, getStockUnit(ingredient));
  }

  String formatRequiredQuantity(String ingredient, double value) {
    return formatQuantityWithUnit(value, getIngredientUnit(ingredient));
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

  String _displayUnitLabel(String unit) {
    final normalized = _normalizeUnit(unit);
    if (normalized == 'gr') return 'kg';
    if (normalized == 'ml') return 'L';
    if (normalized == 'l') return 'L';
    if (normalized == 'kg') return 'kg';
    if (normalized == 'butir') return 'butir';
    return unit.trim().isEmpty ? 'unit' : unit.trim();
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double _convertToStockUnit({
    required String ingredient,
    required double amount,
    required String fromUnit,
    String? overrideStockUnit,
  }) {
    final stockUnit = _normalizeUnit(
      overrideStockUnit ?? getStockUnit(ingredient),
    );
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

  String? _datasetProductName(String ingredient) {
    final value = ingredient.toLowerCase();

    if (value.contains('tepung terigu') || value == 'tepung') {
      return 'Tepung Terigu 1kg';
    }
    if (value.contains('telur')) return 'Telur 1kg';
    if (value.contains('gula pasir') || value == 'gula') {
      return 'Gula Pasir 1kg';
    }
    if (value.contains('susu bubuk') || value == 'susu') {
      return 'Susu Bubuk 27gr';
    }
    if (value.contains('cokelat') || value.contains('coklat')) {
      return 'Cokelat Bubuk 250gr';
    }
    if (value.contains('mentega')) return 'Mentega 500gr';
    if (value.contains('keju')) return 'Keju Parut 250gr';
    if (value.contains('baking powder')) return 'Baking Powder 45gr';

    return null;
  }

  String _datasetCategory(String datasetProductName) {
    return datasetCategories[datasetProductName] ?? 'Bahan Tambahan';
  }

  int _datasetPrice(String datasetProductName) {
    return datasetMedianPrices[datasetProductName] ?? 1;
  }

  void _clearPredictionResult() {
    predictedDemand = null;
    predictionRawValue = null;
    predictionR2 = null;
    predictionMae = null;
    predictionRmse = null;
    predictionModelProduct = null;
  }

  String? _primaryIngredientForPrediction() {
    if (selectedRecipe == null) return null;

    final ingredients = recipeIngredients[selectedRecipe] ?? {};
    if (ingredients.isEmpty) return null;

    String? selectedIngredient;
    double highestNeed = -1;

    ingredients.forEach((ingredient, details) {
      if (!isIngredientSelected(ingredient)) return;
      if (_datasetProductName(ingredient) == null) return;

      final quantity = _toDouble(details['quantity']);
      final unit = details['unit']?.toString() ?? getIngredientUnit(ingredient);
      final stockNeed = _convertToStockUnit(
        ingredient: ingredient,
        amount: quantity,
        fromUnit: unit,
      );

      if (stockNeed > highestNeed) {
        highestNeed = stockNeed;
        selectedIngredient = ingredient;
      }
    });

    return selectedIngredient;
  }

  double _quantityPerUnitInStockUnit(String ingredient) {
    if (selectedRecipe == null) return 0;
    final details = recipeIngredients[selectedRecipe]?[ingredient];
    if (details == null) return 0;

    return _convertToStockUnit(
      ingredient: ingredient,
      amount: _toDouble(details['quantity']),
      fromUnit: details['unit']?.toString() ?? getIngredientUnit(ingredient),
    );
  }

  double _datasetDemandToStockUnit({
    required String ingredient,
    required double demand,
  }) {
    final packageGram = _datasetPackageGram(ingredient);
    return _convertToStockUnit(
      ingredient: ingredient,
      amount: demand * packageGram,
      fromUnit: 'gr',
      overrideStockUnit: getStockUnit(ingredient),
    );
  }

  double _datasetPackageGram(String ingredient) {
    final matchedName = _matchingProductName(ingredient) ?? ingredient;

    for (final entry in datasetPackageSizes.entries) {
      if (_ingredientKey(entry.key) == _ingredientKey(matchedName) ||
          _ingredientKey(entry.key) == _ingredientKey(ingredient)) {
        return entry.value;
      }
    }

    final lower = matchedName.toLowerCase();
    final gramMatch = RegExp(
      r'(\d+(?:[,.]\d+)?)\s*(gr|g|gram)\b',
    ).firstMatch(lower);
    if (gramMatch != null) {
      return double.parse(gramMatch.group(1)!.replaceAll(',', '.'));
    }

    final kgMatch = RegExp(
      r'(\d+(?:[,.]\d+)?)\s*(kg|kilogram)\b',
    ).firstMatch(lower);
    if (kgMatch != null) {
      return double.parse(kgMatch.group(1)!.replaceAll(',', '.')) * 1000;
    }

    return 1000;
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
          rawValue: predictionRawValue,
          estimatedNeeds: buildEstimatedNeedsText(),
          accuracyR2: predictionR2,
          errorMae: predictionMae,
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
