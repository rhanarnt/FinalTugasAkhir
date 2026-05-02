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
      final available = currentStock[ingredient] ?? 0;
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
    final unit = productUnits[ingredient];
    if (unit != null && unit.isNotEmpty) return unit;
    return 'kg';
  }

  double toGram({required double amount, required String unit}) {
    final normalized = unit.toLowerCase();
    if (normalized == 'gr') return amount;
    if (normalized == 'kg') return amount * 1000;
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
    final available = currentStock[ingredient] ?? 0;
    return available >= required
        ? const Color(0xFF10B981)
        : const Color(0xFFDC2626);
  }

  String cleanIngredientName(String ingredient) {
    return ingredient.replaceAll(RegExp(r' \d+(kg|gr)'), '').trim();
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

  double _convertToStockUnit({
    required String ingredient,
    required double amount,
    required String fromUnit,
  }) {
    final stockUnit = getStockUnit(ingredient).toLowerCase();
    final unit = fromUnit.toLowerCase();

    if (unit == stockUnit) return amount;

    if (unit == 'gr' && stockUnit == 'kg') return amount / 1000;
    if (unit == 'kg' && stockUnit == 'gr') return amount * 1000;

    if (unit == 'butir' && stockUnit == 'kg') {
      return (amount * eggGramPerButir) / 1000;
    }
    if (unit == 'butir' && stockUnit == 'gr') {
      return amount * eggGramPerButir;
    }
    if (unit == 'kg' && stockUnit == 'butir') {
      return (amount * 1000) / eggGramPerButir;
    }
    if (unit == 'gr' && stockUnit == 'butir') {
      return amount / eggGramPerButir;
    }

    return amount;
  }

  double _roundRequiredGramToKg(double grams) {
    if (grams <= 0) return 0;
    return MLService.gramsToKgRounded(grams);
  }

  Map<String, double> get roundedUsage {
    final required = requiredIngredients;
    final rounded = <String, double>{};

    required.forEach((ingredient, neededAmount) {
      if (!isIngredientSelected(ingredient)) return;
      final unit = getIngredientUnit(ingredient);
      final requiredGram = toGram(amount: neededAmount, unit: unit);
      rounded[ingredient] = _roundRequiredGramToKg(requiredGram);
    });

    return rounded;
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

      final rounded = roundedUsage;
      if (rounded.isEmpty) {
        return {'status': 'error', 'message': 'Tidak ada bahan yang dipilih'};
      }

      final items =
          rounded.entries.where((entry) => entry.value > 0).map((entry) {
            final ingredient = entry.key;
            final quantityKg = entry.value;
            return {
              'product_id': productIds[ingredient],
              'product_name': ingredient,
              'quantity': quantityKg,
              'unit': 'kg',
            };
          }).toList();

      final result = await MLService.consumeStock(
        items: items,
        recipeName: selectedRecipe,
        productionQuantity: productionQuantity,
      );

      if (result['status'] == 'success') {
        for (final entry in rounded.entries) {
          final ingredient = entry.key;
          final quantity = entry.value;
          final available = currentStock[ingredient] ?? 0;
          currentStock[ingredient] = (available - quantity).clamp(
            0,
            double.infinity,
          );
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
