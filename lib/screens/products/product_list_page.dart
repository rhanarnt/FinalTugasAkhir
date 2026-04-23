import 'package:finalproject/models/product_model.dart';
import 'package:finalproject/theme/colors.dart';
import 'package:finalproject/theme/text_styles.dart';
import 'package:flutter/material.dart';

import 'product_list_controller.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final ProductListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProductListController();
    _controller.loadProducts().catchError((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal memuat data produk'),
          backgroundColor: AppColors.statusError,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgLight,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(160),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryBrown,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data Produk',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_controller.products.length} Produk',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.bgWhite,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: TextField(
                          onChanged: _controller.setSearchQuery,
                          decoration: InputDecoration(
                            hintText: 'Cari produk...',
                            hintStyle: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _controller.loadProducts,
            color: AppColors.primaryBrown,
            child:
                _controller.isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF8B6E58),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Memuat data produk...'),
                        ],
                      ),
                    )
                    : SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            color: AppColors.bgWhite,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    ['semua', 'tersedia', 'rendah', 'kritis']
                                        .map(
                                          (filter) => Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: FilterChip(
                                              label: Text(
                                                _controller.capitalize(filter),
                                                style: AppTextStyles.labelSmall
                                                    .copyWith(
                                                      color:
                                                          _controller.selectedFilter ==
                                                                  filter
                                                              ? Colors.white
                                                              : AppColors
                                                                  .textSecondary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              backgroundColor:
                                                  _controller.selectedFilter ==
                                                          filter
                                                      ? AppColors.primaryBrown
                                                      : AppColors.bgLight,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: BorderSide(
                                                  color:
                                                      _controller.selectedFilter ==
                                                              filter
                                                          ? AppColors
                                                              .primaryBrown
                                                          : AppColors.grey200,
                                                  width: 1,
                                                ),
                                              ),
                                              onSelected:
                                                  (_) => _controller.setFilter(
                                                    filter,
                                                  ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child:
                                _controller.filteredProducts.isNotEmpty
                                    ? Column(
                                      children:
                                          _controller.filteredProducts
                                              .map(
                                                (product) =>
                                                    _buildProductCard(product),
                                              )
                                              .toList()
                                              .expand(
                                                (card) => [
                                                  card,
                                                  const SizedBox(height: 12),
                                                ],
                                              )
                                              .toList(),
                                    )
                                    : Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 60,
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: AppColors.grey200,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Icon(
                                                Icons.shopping_bag_outlined,
                                                size: 40,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Produk Tidak Ditemukan',
                                              style: AppTextStyles.headlineSmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Coba ubah filter atau cari dengan kata kunci lain',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.popUntil(context, (route) => route.isFirst);
                  break;
                case 2:
                  Navigator.pushNamed(context, '/transaction');
                  break;
                case 3:
                  Navigator.pushNamed(context, '/prediction');
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

  Widget _buildProductCard(Product product) {
    final maxStock = _controller.maxStock;
    final stockPercentage = (product.stock / maxStock * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.shadowLight],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _controller
                      .getStatusColor(product.status)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _controller.getCategoryIcon(product.category),
                  color: _controller.getStatusColor(product.status),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBrown.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primaryBrown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _controller.formatPrice(product.price),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _controller
                      .getStatusColor(product.status)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _controller
                        .getStatusColor(product.status)
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _controller.getStatusLabel(product.status),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _controller.getStatusColor(product.status),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.grey200),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stok Tersedia',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.stock} ${product.unit}',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kapasitas',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$stockPercentage%',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: product.stock / maxStock,
                        minHeight: 6,
                        backgroundColor: AppColors.grey200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _controller.getStatusColor(product.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} - Detail'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryBrown,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
