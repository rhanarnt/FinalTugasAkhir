import 'package:flutter/material.dart';

import 'prediction_controller.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  late final PredictionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PredictionController();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final error = await _controller.loadRecipes();
    if (!mounted || error == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(200),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFA89080),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                              child: const Icon(
                                Icons.calculate,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
          body:
              _controller.isLoading
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
                  : _controller.recipes.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Color(0xFFDC2626),
                        ),
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              color: const Color(0xFFE5E7EB),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _controller.selectedRecipe,
                                              hint: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
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
                                                padding: EdgeInsets.only(
                                                  right: 12,
                                                ),
                                                child: Icon(
                                                  Icons.expand_more,
                                                  color: Color(0xFF9CA3AF),
                                                ),
                                              ),
                                              items:
                                                  _controller.recipes
                                                      .map(
                                                        (
                                                          recipe,
                                                        ) => DropdownMenuItem<
                                                          String
                                                        >(
                                                          value:
                                                              recipe['recipe_name']
                                                                  as String,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                ),
                                                            child: Text(
                                                              recipe['recipe_name']
                                                                  as String,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                              onChanged:
                                                  _controller.setSelectedRecipe,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          onChanged:
                                              _controller.setProductionQuantity,
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: const TextStyle(
                                              color: Color(0xFF9CA3AF),
                                            ),
                                            suffixText: 'pcs',
                                            suffixStyle: const TextStyle(
                                              color: Color(0xFF9CA3AF),
                                              fontSize: 12,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed:
                                                _controller.canCalculate
                                                    ? _controller.calculate
                                                    : null,
                                            icon: const Icon(
                                              Icons.calculate,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Hitung Kebutuhan',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFA89080,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        OutlinedButton(
                                          onPressed: _controller.reset,
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFFE5E7EB),
                                              width: 1,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                              if (_controller.isCalculated) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        _controller.isStockSufficient
                                            ? const Color(
                                              0xFF10B981,
                                            ).withOpacity(0.1)
                                            : const Color(
                                              0xFFDC2626,
                                            ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          _controller.isStockSufficient
                                              ? const Color(
                                                0xFF10B981,
                                              ).withOpacity(0.3)
                                              : const Color(
                                                0xFFDC2626,
                                              ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color:
                                              _controller.isStockSufficient
                                                  ? const Color(
                                                    0xFF10B981,
                                                  ).withOpacity(0.2)
                                                  : const Color(
                                                    0xFFDC2626,
                                                  ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          _controller.isStockSufficient
                                              ? Icons.check_circle
                                              : Icons.warning_amber,
                                          color:
                                              _controller.isStockSufficient
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFFDC2626),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _controller.isStockSufficient
                                                  ? 'Stok Cukup'
                                                  : 'Stok Belum Cukup',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    _controller
                                                            .isStockSufficient
                                                        ? const Color(
                                                          0xFF10B981,
                                                        )
                                                        : const Color(
                                                          0xFFDC2626,
                                                        ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _controller.isStockSufficient
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
                                const Text(
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
                                    children:
                                        _controller.requiredIngredients.entries.toList().asMap().entries.map((
                                          entry,
                                        ) {
                                          final isLast =
                                              entry.key ==
                                              _controller
                                                      .requiredIngredients
                                                      .length -
                                                  1;
                                          final ingredient = entry.value.key;
                                          final neededAmount =
                                              entry.value.value;
                                          final availableAmount =
                                              _controller
                                                  .currentStock[ingredient] ??
                                              0;
                                          final unit = _controller
                                              .getIngredientUnit(ingredient);
                                          final isSufficient =
                                              availableAmount >= neededAmount;

                                          return Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  14,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                _controller
                                                                    .cleanIngredientName(
                                                                      ingredient,
                                                                    ),
                                                                style: const TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Color(
                                                                    0xFF1F2937,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 6,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const Text(
                                                                          'Kebutuhan',
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                11,
                                                                            color: Color(
                                                                              0xFF9CA3AF,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '$neededAmount $unit',
                                                                          style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color: Color(
                                                                              0xFF1F2937,
                                                                            ),
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
                                                                        const Text(
                                                                          'Stok Saat Ini',
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                11,
                                                                            color: Color(
                                                                              0xFF9CA3AF,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '$availableAmount $unit',
                                                                          style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color: Color(
                                                                              0xFF1F2937,
                                                                            ),
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
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 6,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: _controller
                                                                .getStatusColor(
                                                                  ingredient,
                                                                )
                                                                .withOpacity(
                                                                  0.15,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            border: Border.all(
                                                              color: _controller
                                                                  .getStatusColor(
                                                                    ingredient,
                                                                  )
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            isSufficient
                                                                ? 'Aman'
                                                                : 'Kurang',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: _controller
                                                                  .getStatusColor(
                                                                    ingredient,
                                                                  ),
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
                                                  color: const Color(
                                                    0xFFF3F4F6,
                                                  ),
                                                ),
                                            ],
                                          );
                                        }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (!_controller.isStockSufficient) ...[
                                  const Text(
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
                                      color: const Color(
                                        0xFFDC2626,
                                      ).withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFDC2626,
                                        ).withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          _controller.insufficientStock.entries.map((
                                            entry,
                                          ) {
                                            final ingredient = entry.key;
                                            final deficitAmount = entry.value;
                                            final unit = _controller
                                                .getIngredientUnit(ingredient);

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      _controller
                                                          .cleanIngredientName(
                                                            ingredient,
                                                          ),
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(
                                                          0xFF1F2937,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFDC2626,
                                                      ).withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '+$deficitAmount $unit',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Color(
                                                          0xFFDC2626,
                                                        ),
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
                                  child: const Column(
                                    children: [
                                      _EmptyCalcIcon(),
                                      SizedBox(height: 16),
                                      Text(
                                        'Belum Ada Kalkulasi',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
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
                case 5:
                  Navigator.pushNamed(context, '/settings');
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
                label: 'Stock In',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.trending_up_outlined),
                label: 'Prediksi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.description_outlined),
                label: 'Laporan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                label: 'Pengaturan',
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _EmptyCalcIcon extends StatelessWidget {
  const _EmptyCalcIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF9CA3AF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.calculate, color: Color(0xFF9CA3AF), size: 32),
      ),
    );
  }
}
