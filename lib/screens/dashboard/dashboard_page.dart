import 'package:finalproject/theme/colors.dart';
import 'package:finalproject/theme/text_styles.dart';
import 'package:flutter/material.dart';

import 'dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgLight,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(240),
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
                        vertical: 6,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.notifications_none,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () {},
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: AppColors.statusError,
                                        borderRadius: BorderRadius.circular(11),
                                        border: Border.all(
                                          color: AppColors.primaryBrown,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '3',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat Datang',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Admin Sulastri',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
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
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Total Penjualan',
                              value: 'Rp 67 Jt',
                              change: '+12.5%',
                              icon: Icons.trending_up,
                              iconBgColor: AppColors.statusSuccess,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Produk',
                              value: '24',
                              change: 'Aktif',
                              icon: Icons.shopping_bag,
                              iconBgColor: AppColors.secondaryBlue,
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgWhite,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [AppColors.shadowLight],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Grafik Penjualan',
                                      style: AppTextStyles.headlineSmall
                                          .copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '6 Bulan Terakhir',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.trending_up,
                                  color: AppColors.statusSuccess,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 200,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...[
                                    '80000000',
                                    '60000000',
                                    '40000000',
                                    '20000000',
                                    '0',
                                  ].map((label) {
                                    return Text(
                                      label,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.grey300,
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:
                                  [
                                    'Jan',
                                    'Feb',
                                    'Mar',
                                    'Apr',
                                    'Mei',
                                    'Jun',
                                  ].map((month) {
                                    return Text(
                                      month,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgWhite,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [AppColors.shadowLight],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.statusWarning,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Stok Menipis',
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ..._controller.lowStockItems.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: AppTextStyles.labelLarge
                                                .copyWith(
                                                  color: AppColors.textPrimary,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Stok: ${item['stock']}',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: AppColors.textTertiary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: item['statusColor'],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item['status'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/prediction');
                              },
                              icon: const Icon(Icons.trending_up, size: 20),
                              label: const Text(
                                'Lihat Prediksi',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.check_circle, size: 20),
                              label: const Text(
                                'Rekomendasi Stok',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.statusSuccess,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _controller.selectedIndex,
            onTap: (index) {
              _controller.setSelectedIndex(index);
              switch (index) {
                case 0:
                  break;
                case 1:
                  Navigator.of(context).pushNamed('/products');
                  break;
                case 2:
                  Navigator.of(context).pushNamed('/transaction');
                  break;
                case 3:
                  Navigator.of(context).pushNamed('/prediction');
                  break;
                case 4:
                  Navigator.of(context).pushNamed('/reports');
                  break;
                case 5:
                  Navigator.of(context).pushNamed('/settings');
                  break;
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppColors.shadowLight],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      change,
                      style: AppTextStyles.bodySmall.copyWith(
                        color:
                            change.contains('+')
                                ? AppColors.statusSuccess
                                : AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Icon(icon, color: iconBgColor, size: 22)),
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
