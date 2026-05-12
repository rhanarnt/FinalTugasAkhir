import 'package:finalproject/theme/colors.dart';
import 'package:finalproject/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'report_controller.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  late final ReportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReportController();
    _controller.loadReports();
    _controller.startAutoRefresh();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Kritis':
        return AppColors.statusError;
      case 'Rendah':
        return AppColors.statusWarning;
      default:
        return AppColors.statusSuccess;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - 48) / 2;

    final usageBars = _buildUsageBars(_controller.usageSummary);
    final usagePie = _buildUsagePie(usageBars);
    final List<double> demandTrend =
        _controller.demandTrend.isNotEmpty
            ? _controller.demandTrend
            : const <double>[28, 32, 40, 36, 44, 50, 48];

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBrown,
        elevation: 0,
        title: Text(
          'Laporan & Analitik',
          style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading &&
              _controller.stockItems.isEmpty &&
              _controller.stockHistory.isEmpty &&
              _controller.predictionItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => _controller.loadReports(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_controller.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.statusError.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.statusError.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _controller.errorMessage!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.statusError,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildSummaryCard(
                        width: cardWidth,
                        title: 'Total Produk',
                        value: _controller.totalProduk.toString(),
                        icon: Icons.shopping_bag,
                        color: AppColors.secondaryBlue,
                      ),
                      _buildSummaryCard(
                        width: cardWidth,
                        title: 'Total Bahan',
                        value: _controller.totalBahan.toString(),
                        icon: Icons.inventory_2,
                        color: AppColors.primaryBrown,
                      ),
                      _buildSummaryCard(
                        width: cardWidth,
                        title: 'Stok Kritis',
                        value: _controller.totalKritis.toString(),
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.statusError,
                      ),
                      _buildSummaryCard(
                        width: cardWidth,
                        title: 'Total Prediksi',
                        value: _controller.totalPrediksi.toString(),
                        icon: Icons.trending_up,
                        color: AppColors.statusSuccess,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Laporan Stok Bahan'),
                  const SizedBox(height: 12),
                  _buildStockTable(_controller.stockItems),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Riwayat Stok Masuk'),
                  const SizedBox(height: 12),
                  _buildStockHistory(_controller.stockHistory),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Laporan Prediksi Permintaan'),
                  const SizedBox(height: 12),
                  _buildPredictionList(_controller.predictionItems),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Grafik Penggunaan Bahan'),
                  const SizedBox(height: 12),
                  _buildCharts(usageBars, usagePie, demandTrend),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Bahan Kritis'),
                  const SizedBox(height: 12),
                  _buildCriticalItems(_controller.criticalItems),
                  const SizedBox(height: 24),
                  _buildExportButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
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
            case 3:
              Navigator.pushNamed(context, '/prediction');
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
            label: 'Stok Masuk',
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
  }

  Widget _buildSummaryCard({
    required double width,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppColors.shadowLight],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildStockTable(List<Map<String, dynamic>> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.shadowLight],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:
            items.isEmpty
                ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Data stok bahan belum tersedia.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
                : DataTable(
                  columns: const [
                    DataColumn(label: Text('Nama Bahan')),
                    DataColumn(label: Text('Stok Tersedia')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows:
                      items.map((item) {
                        final statusColor = _statusColor(
                          item['status'] as String,
                        );
                        final unit = item['unit']?.toString() ?? 'kg';
                        return DataRow(
                          cells: [
                            DataCell(Text(item['name'] as String)),
                            DataCell(Text('${item['stock']} $unit')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['status'] as String,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
      ),
    );
  }

  Widget _buildStockHistory(List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.shadowLight],
      ),
      child: Column(
        children:
            items.isEmpty
                ? [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Belum ada riwayat stok masuk.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ]
                : items
                    .map(
                      (entry) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBrown.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primaryBrown,
                          ),
                        ),
                        title: Text(
                          entry['name'] as String,
                          style: AppTextStyles.labelLarge,
                        ),
                        subtitle: Text(
                          _dateFormat.format(entry['date'] as DateTime),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        trailing: Text(
                          '+${entry['amount']} ${entry['unit'] ?? 'kg'}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.statusSuccess,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
      ),
    );
  }

  Widget _buildPredictionList(List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.shadowLight],
      ),
      child: Column(
        children:
            items.isEmpty
                ? [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Belum ada data prediksi.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ]
                : items
                    .map(
                      (item) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBlue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.trending_up,
                            color: AppColors.secondaryBlue,
                          ),
                        ),
                        title: Text(
                          item['product'] as String,
                          style: AppTextStyles.labelLarge,
                        ),
                        subtitle: Text(
                          '${item['needs']} • ${_dateFormat.format(item['date'] as DateTime)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        trailing: Text(
                          '${item['prediction']} unit',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primaryBrown,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
      ),
    );
  }

  Widget _buildCharts(
    List<Map<String, dynamic>> usageBars,
    List<Map<String, dynamic>> usagePie,
    List<double> demandTrend,
  ) {
    return Column(
      children: [
        _buildChartCard(
          title: 'Bar Chart Penggunaan Bahan',
          child: SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= usageBars.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            usageBars[value.toInt()]['label'] as String,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups:
                    usageBars.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value['value'] as double,
                            color: entry.value['color'] as Color,
                            width: 18,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          title: 'Line Chart Permintaan Produk',
          child: SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'M${value.toInt() + 1}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        demandTrend
                            .asMap()
                            .entries
                            .map(
                              (entry) =>
                                  FlSpot(entry.key.toDouble(), entry.value),
                            )
                            .toList(),
                    isCurved: true,
                    color: AppColors.secondaryBlue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.secondaryBlue.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          title: 'Pie Chart Bahan Paling Sering Digunakan',
          child: SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections:
                    usagePie.map((entry) {
                      return PieChartSectionData(
                        value: entry['value'] as double,
                        color: entry['color'] as Color,
                        radius: 50,
                        showTitle: true,
                        title: '${entry['value']}%',
                        titleStyle: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.shadowLight],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCriticalItems(List<Map<String, dynamic>> criticalItems) {
    if (criticalItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.shadowLight],
        ),
        child: Text(
          'Tidak ada bahan kritis saat ini.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.shadowLight],
      ),
      child: Column(
        children:
            criticalItems
                .map(
                  (item) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.statusError.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.statusError,
                      ),
                    ),
                    title: Text(
                      item['name'] as String,
                      style: AppTextStyles.labelLarge,
                    ),
                    subtitle: Text(
                      'Sisa stok: ${item['stock']} ${item['unit'] ?? 'kg'}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/transaction');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusSuccess,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Tambah Stok',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export laporan masih menggunakan data dummy.'),
            ),
          );
        },
        icon: const Icon(Icons.download_rounded),
        label: const Text('Export Laporan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBrown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildUsageBars(
    List<Map<String, dynamic>> usageSummary,
  ) {
    if (usageSummary.isEmpty) {
      return [
        {'label': 'Tepung', 'value': 40.0, 'color': AppColors.primaryBrown},
        {'label': 'Gula', 'value': 28.0, 'color': AppColors.secondaryOrange},
        {'label': 'Telur', 'value': 18.0, 'color': AppColors.secondaryBlue},
        {'label': 'Mentega', 'value': 12.0, 'color': AppColors.secondaryGreen},
      ];
    }

    final colors = [
      AppColors.primaryBrown,
      AppColors.secondaryOrange,
      AppColors.secondaryBlue,
      AppColors.secondaryGreen,
    ];

    return usageSummary.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return {
        'label': item['label'] as String,
        'value': item['value'] as double,
        'color': colors[index % colors.length],
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildUsagePie(
    List<Map<String, dynamic>> usageBars,
  ) {
    final total = usageBars.fold<double>(
      0,
      (sum, item) => sum + (item['value'] as double),
    );
    if (total == 0) {
      return usageBars;
    }

    return usageBars
        .map(
          (entry) => {
            'label': entry['label'],
            'value': ((entry['value'] as double) / total) * 100,
            'color': entry['color'],
          },
        )
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
