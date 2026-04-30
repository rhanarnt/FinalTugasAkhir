import 'package:finalproject/services/ml_service.dart';
import 'package:flutter/material.dart';

class PredictionController extends ChangeNotifier {
  String? selectedRecipe;
  int productionQuantity = 0;
  bool isCalculated = false;
  bool isLoading = true;

  List<Map<String, dynamic>> recipes = [];
  Map<String, Map<String, dynamic>> recipeIngredients = {};
  Map<String, bool> ingredientSelections = {};

  final Map<String, int> currentStock = {
    'Tepung Terigu 1kg': 45000,
    'Telur 1kg': 12,
    'Gula Pasir 1kg': 28000,
    'Susu Bubuk': 8000,
    'Cokelat Bubuk 250gr': 22000,
    'Mentega 500gr': 15000,
    'Keju Parut 250gr': 3000,
    'Baking Powder': 60000,
  };

  Future<String?> loadRecipes() async {
    isLoading = true;
    notifyListeners();

    try {
      final fetchedRecipes = await MLService.getRecipes();
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

      _initializeIngredientSelections();

      return null;
    } catch (e) {
      return 'Gagal memuat resep: $e';
    } finally {
      isLoading = false;
      notifyListeners();
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

  Map<String, int> get requiredIngredients {
    if (selectedRecipe == null || productionQuantity == 0) {
      return {};
    }

    final ingredients = recipeIngredients[selectedRecipe] ?? {};
    final required = <String, int>{};

    ingredients.forEach((productName, details) {
      if (!isIngredientSelected(productName)) return;
      final quantity = (details['quantity'] as num).toInt();
      required[productName] = quantity * productionQuantity;
    });

    return required;
  }

  Map<String, int> get insufficientStock {
    final required = requiredIngredients;
    final insufficient = <String, int>{};

    required.forEach((ingredient, neededAmount) {
      final available = currentStock[ingredient] ?? 0;
      if (available < neededAmount) {
        insufficient[ingredient] = neededAmount - available;
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

  Color getStatusColor(String ingredient) {
    final required = requiredIngredients[ingredient] ?? 0;
    final available = currentStock[ingredient] ?? 0;
    return available >= required
        ? const Color(0xFF10B981)
        : const Color(0xFFDC2626);
  }

  String cleanIngredientName(String ingredient) {
    return ingredient.replaceAll(RegExp(r' \d+(kg|gr)'), '').trim();
  }
}
