import 'package:flutter/material.dart';
import 'package:finalproject/theme/colors.dart';
import 'package:finalproject/theme/text_styles.dart';
import 'package:finalproject/services/ml_service.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({Key? key}) : super(key: key);

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  String? _selectedRecipe;
  int _productionQuantity = 0;
  bool _isCalculated = false;
  bool _isLoading = true;

  // Data dari API
  List<Map<String, dynamic>> recipes = [];
  Map<String, Map<String, dynamic>> recipeIngredients = {};

  // Stok saat ini (sama dengan di product list)
  final Map<String, int> currentStock = {
    'Tepung Terigu 1kg': 45000, // gram
    'Telur 1kg': 12, // butir
    'Gula Pasir 1kg': 28000, // gram
    'Susu Bubuk': 8000, // gram
    'Cokelat Bubuk 250gr': 22000, // gram
    'Mentega 500gr': 15000, // gram
    'Keju Parut 250gr': 3000, // gram
    'Baking Powder': 60000, // gram
  };

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      final fetchedRecipes = await MLService.getRecipes();

      setState(() {
        recipes = fetchedRecipes;

        // Build recipeIngredients map
        for (var recipe in recipes) {
          recipeIngredients[recipe['recipe_name']] = {};

          if (recipe['ingredients'] != null) {
            for (var ingredient in recipe['ingredients']) {
              recipeIngredients[recipe['recipe_name']]![ingredient['product_name']] = {
                'quantity': ingredient['quantity_needed'],
                'unit': ingredient['unit'],
              };
            }
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      print('Error loading recipes: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat resep: $e')),
      );
    }
  }

  Map<String, int> get requiredIngredients {
    if (_selectedRecipe == null || _productionQuantity == 0) {
      return {};
    }

    final ingredients = recipeIngredients[_selectedRecipe] ?? {};
    final required = <String, int>{};

    ingredients.forEach((productName, details) {
      final quantity = (details['quantity'] as num).toInt();
      required[productName] = quantity * _productionQuantity;
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

  String _getIngredientUnit(String ingredient) {
    if (_selectedRecipe == null) return 'gr';
    final recipeIngs = recipeIngredients[_selectedRecipe];
    if (recipeIngs == null) return 'gr';
    final ingData = recipeIngs[ingredient];
    if (ingData == null) return 'gr';
    return ingData['unit'] as String? ?? 'gr';
  }

  Color _getStatusColor(String ingredient) {
    final required = requiredIngredients[ingredient] ?? 0;
    final available = currentStock[ingredient] ?? 0;
    return available >= required ? Color(0xFF10B981) : Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      // Brown Header
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFA89080),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button + Title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Prediksi Kebutuhan Bahan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Kalkulasi bahan berdasarkan rencana produksi',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.calculate,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Sistem Kalkulasi Otomatis',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Pilih produk dan jumlah untuk lihat kebutuhan bahan',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat resep...'),
                ],
              ),
            )
          : recipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Color(0xFFDC2626)),
                      const SizedBox(height: 16),
                      const Text('Gagal memuat resep'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadRecipes,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input Form Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rencana Produksi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Product Selection
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pilih Produk',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedRecipe,
                                  hint: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      '-- Pilih Produk --',
                                      style: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  isExpanded: true,
                                  icon: const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Icon(Icons.expand_more,
                                        color: Color(0xFF9CA3AF)),
                                  ),
                                  items: recipes
                                      .map((recipe) =>
                                          DropdownMenuItem<String>(
                                            value: recipe['recipe_name'] as String,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Text(recipe['recipe_name'] as String),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedRecipe = value;
                                      _isCalculated = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Quantity Input
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jumlah Produksi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _productionQuantity =
                                      int.tryParse(value) ?? 0;
                                  _isCalculated = false;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle:
                                    const TextStyle(color: Color(0xFF9CA3AF)),
                                suffixText: 'pcs',
                                suffixStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Calculate Button
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: (_selectedRecipe != null &&
                                        _productionQuantity > 0)
                                    ? () {
                                        setState(() => _isCalculated = true);
                                      }
                                    : null,
                                icon: const Icon(Icons.calculate, size: 18),
                                label: const Text(
                                  'Hitung Kebutuhan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFA89080),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedRecipe = null;
                                  _productionQuantity = 0;
                                  _isCalculated = false;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Results Section
                  if (_isCalculated) ...[
                    // Status Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isStockSufficient
                            ? Color(0xFF10B981).withOpacity(0.1)
                            : Color(0xFFDC2626).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isStockSufficient
                              ? Color(0xFF10B981).withOpacity(0.3)
                              : Color(0xFFDC2626).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isStockSufficient
                                  ? Color(0xFF10B981).withOpacity(0.2)
                                  : Color(0xFFDC2626).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isStockSufficient
                                  ? Icons.check_circle
                                  : Icons.warning_amber,
                              color: isStockSufficient
                                  ? Color(0xFF10B981)
                                  : Color(0xFFDC2626),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isStockSufficient
                                      ? 'Stok Cukup'
                                      : 'Stok Belum Cukup',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isStockSufficient
                                        ? Color(0xFF10B981)
                                        : Color(0xFFDC2626),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isStockSufficient
                                      ? 'Semua bahan tersedia untuk produksi'
                                      : 'Ada bahan yang perlu ditambah',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ingredients Table
                    Text(
                      'Kebutuhan Bahan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: requiredIngredients.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          final isLast =
                              entry.key == requiredIngredients.length - 1;
                          final ingredient = entry.value.key;
                          final neededAmount = entry.value.value;
                          final availableAmount =
                              currentStock[ingredient] ?? 0;
                          final unit = _getIngredientUnit(ingredient);
                          final isSufficient =
                              availableAmount >= neededAmount;

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ingredient
                                                    .replaceAll(
                                                        RegExp(r' \d+(kg|gr)'),
                                                        '')
                                                    .trim(),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Kebutuhan',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xFF9CA3AF),
                                                          ),
                                                        ),
                                                        Text(
                                                          '$neededAmount $unit',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                                0xFF1F2937),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Stok Saat Ini',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xFF9CA3AF),
                                                          ),
                                                        ),
                                                        Text(
                                                          '$availableAmount $unit',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                                0xFF1F2937),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(ingredient)
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: _getStatusColor(ingredient)
                                                  .withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            isSufficient ? 'Aman' : 'Kurang',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: _getStatusColor(
                                                  ingredient),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  height: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recommendation Card
                    if (!isStockSufficient) ...[
                      Text(
                        'Rekomendasi Penambahan Stok',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFDC2626).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFFDC2626).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: insufficientStock.entries
                              .map((entry) {
                            final ingredient = entry.key;
                            final deficitAmount = entry.value;
                            final unit = _getIngredientUnit(ingredient);

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      ingredient
                                          .replaceAll(
                                              RegExp(r' \d+(kg|gr)'), '')
                                          .trim(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFDC2626)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '+$deficitAmount $unit',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFDC2626),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ] else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFF9CA3AF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.calculate,
                                color: Color(0xFF9CA3AF), size: 32),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum Ada Kalkulasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pilih produk dan masukkan jumlah produksi untuk melihat kebutuhan bahan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.popUntil(context, (route) => route.isFirst);
              break;
            case 1:
              Navigator.pushNamed(context, '/products');
              break;
            case 2:
              Navigator.pushNamed(context, '/transaction');
              break;
            case 4:
              Navigator.pushNamed(context, '/reports');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            label: 'Prediksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}
