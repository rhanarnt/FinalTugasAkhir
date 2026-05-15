import 'dart:io';

import 'package:finalproject/theme/colors.dart';
import 'package:finalproject/theme/text_styles.dart';
import 'package:finalproject/utils/stock_status.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'report_controller.dart';

enum ExportPeriod {
  daily('Harian', 'harian'),
  biweekly('2 Mingguan', 'dua_mingguan'),
  monthly('Bulanan', 'bulanan');

  const ExportPeriod(this.label, this.fileKey);

  final String label;
  final String fileKey;
}

enum ExportFormat {
  csv('CSV', 'csv', 'csv'),
  pdf('PDF', 'pdf', 'pdf');

  const ExportFormat(this.label, this.fileKey, this.extension);

  final String label;
  final String fileKey;
  final String extension;
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _fileDateFormat = DateFormat('yyyyMMdd_HHmmss');
  final ScrollController _stockTableScrollController = ScrollController();
  final ScrollController _stockHistoryScrollController = ScrollController();
  final ScrollController _predictionScrollController = ScrollController();

  late final ReportController _controller;
  String? _lastExportPath;

  @override
  void initState() {
    super.initState();
    _controller = ReportController();
    _controller.loadReports();
    _controller.startAutoRefresh();
  }

  double _sectionMaxHeight() {
    final height = MediaQuery.of(context).size.height * 0.35;
    if (height < 220) return 220;
    if (height > 360) return 360;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - 48) / 2;

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

          final usageBars = _buildUsageBars(_controller.usageSummary);
          final usagePie = _buildUsagePie(usageBars);
          final List<double> demandTrend = _controller.demandTrend;

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
                        color: AppColors.statusError.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.statusError.withValues(alpha: 0.3),
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
                  _buildSectionTitle(
                    'Laporan Stok Bahan',
                    icon: Icons.inventory_2_outlined,
                    subtitle: 'Pantau stok tersedia dan status tiap bahan.',
                  ),
                  const SizedBox(height: 12),
                  _buildStockTable(_controller.stockItems),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    'Riwayat Stok Masuk',
                    icon: Icons.playlist_add_check_rounded,
                    subtitle: 'Catatan bahan yang baru ditambahkan.',
                  ),
                  const SizedBox(height: 12),
                  _buildStockHistory(_controller.stockHistory),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    'Laporan Prediksi Permintaan',
                    icon: Icons.auto_graph_rounded,
                    subtitle: 'Ringkasan prediksi kebutuhan produk terbaru.',
                  ),
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
                  _buildExportActions(),
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
              color: color.withValues(alpha: 0.15),
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

  Widget _buildSectionTitle(String title, {IconData? icon, String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Icon(icon, size: 18, color: AppColors.primaryBrown),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockTable(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return _buildReportEmptyState(
        icon: Icons.inventory_2_outlined,
        message: 'Data stok bahan belum tersedia.',
      );
    }

    final sortedItems = _sortedStockItems(items);

    return SizedBox(
      height: _reportListHeight(sortedItems.length, itemHeight: 92),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _stockTableScrollController,
        child: ListView.separated(
          controller: _stockTableScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: sortedItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = sortedItems[index];
            final stockValue = StockStatusUtils.parseStock(item['stock']);
            final statusKey = StockStatusUtils.statusFromStock(stockValue);
            final statusColor = StockStatusUtils.color(statusKey);
            final statusLabel = StockStatusUtils.label(statusKey);
            final unit = item['unit']?.toString() ?? 'kg';
            final minimumStock = StockStatusUtils.parseStock(item['min_stock']);

            return _buildReportItemCard(
              icon: Icons.inventory_2_outlined,
              iconColor: statusColor,
              title: item['name']?.toString() ?? '-',
              subtitle: 'Minimum ${_formatQuantity(minimumStock)} $unit',
              trailing: _buildStatusBadge(statusLabel, statusColor),
              footer: Row(
                children: [
                  _buildMetricPill(
                    label: 'Stok',
                    value: '${_formatQuantity(stockValue)} $unit',
                    color: AppColors.primaryBrown,
                  ),
                  const SizedBox(width: 8),
                  _buildMetricPill(
                    label: 'Status',
                    value: statusLabel,
                    color: statusColor,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStockHistory(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return _buildReportEmptyState(
        icon: Icons.playlist_add_check_rounded,
        message: 'Belum ada riwayat stok masuk.',
      );
    }

    return SizedBox(
      height: _reportListHeight(items.length, itemHeight: 86),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _stockHistoryScrollController,
        child: ListView.separated(
          controller: _stockHistoryScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final entry = items[index];
            final amount = StockStatusUtils.parseStock(entry['amount']);
            final unit = entry['unit']?.toString() ?? 'kg';

            return _buildReportItemCard(
              icon: Icons.add_rounded,
              iconColor: AppColors.statusSuccess,
              title: entry['name']?.toString() ?? '-',
              subtitle: _dateFormat.format(entry['date'] as DateTime),
              trailing: Text(
                '+${_formatQuantity(amount)} $unit',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.statusSuccess,
                  fontWeight: FontWeight.w800,
                ),
              ),
              footer: Row(
                children: [
                  _buildMetricPill(
                    label: 'Jumlah',
                    value: '${_formatQuantity(amount)} $unit',
                    color: AppColors.statusSuccess,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPredictionList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return _buildReportEmptyState(
        icon: Icons.auto_graph_rounded,
        message: 'Belum ada data prediksi.',
      );
    }

    return SizedBox(
      height: _reportListHeight(items.length, itemHeight: 104),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _predictionScrollController,
        child: ListView.separated(
          controller: _predictionScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            final prediction = StockStatusUtils.parseStock(item['prediction']);

            return _buildReportItemCard(
              icon: Icons.trending_up_rounded,
              iconColor: AppColors.secondaryBlue,
              title: item['product']?.toString() ?? '-',
              subtitle: _dateFormat.format(item['date'] as DateTime),
              trailing: Text(
                '${_formatQuantity(prediction)} unit',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primaryBrown,
                  fontWeight: FontWeight.w800,
                ),
              ),
              footer: Text(
                item['needs']?.toString() ?? '-',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _reportListHeight(int itemCount, {required double itemHeight}) {
    final contentHeight = (itemCount * itemHeight) + ((itemCount - 1) * 10);
    final maxHeight = _sectionMaxHeight();
    if (contentHeight < itemHeight) return itemHeight;
    return contentHeight < maxHeight ? contentHeight : maxHeight;
  }

  Widget _buildReportEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textTertiary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItemCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required Widget footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              trailing,
            ],
          ),
          const SizedBox(height: 12),
          footer,
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _buildMetricPill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 0,
            ),
            children: [
              TextSpan(text: '$label  '),
              TextSpan(
                text: value,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
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
          child:
              usageBars.isEmpty
                  ? _buildEmptyChartState(
                    icon: Icons.inventory_2_outlined,
                    message:
                        'Belum ada data penggunaan bahan. Jalankan prediksi dan simpan hasil produksi agar grafik terisi.',
                  )
                  : SizedBox(
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
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 != 0) {
                                  return const SizedBox.shrink();
                                }
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
          title: 'Tren Permintaan Produk',
          child: _buildDemandTrendChart(demandTrend),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          title: 'Pie Chart Bahan Paling Sering Digunakan',
          child:
              usagePie.isEmpty
                  ? _buildEmptyChartState(
                    icon: Icons.pie_chart_outline_rounded,
                    message:
                        'Belum ada data bahan dari prediksi untuk menghitung bahan yang paling sering digunakan.',
                  )
                  : SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections:
                            usagePie.map((entry) {
                              final value = entry['value'] as double;

                              return PieChartSectionData(
                                value: value,
                                color: entry['color'] as Color,
                                radius: 50,
                                showTitle: value >= 5,
                                title: '${value.toStringAsFixed(1)}%',
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

  Widget _buildDemandTrendChart(List<double> demandTrend) {
    if (demandTrend.isEmpty) {
      return _buildEmptyChartState(
        icon: Icons.show_chart_rounded,
        message:
            'Belum ada data prediksi dari API untuk menampilkan tren permintaan produk.',
      );
    }

    final minDemand = demandTrend.reduce((a, b) => a < b ? a : b);
    final maxDemand = demandTrend.reduce((a, b) => a > b ? a : b);
    final averageDemand =
        demandTrend.fold<double>(0, (sum, value) => sum + value) /
        demandTrend.length;
    final yInterval =
        (maxDemand / 4).ceilToDouble().clamp(1.0, double.infinity).toDouble();
    final maxY = (maxDemand + yInterval).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grafik ini menunjukkan jumlah unit produk yang diprediksi akan diminta pada 7 data prediksi terakhir.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTrendInfoChip(
              icon: Icons.trending_down_rounded,
              label: 'Terendah',
              value: '${_formatQuantity(minDemand)} unit',
              color: AppColors.statusWarning,
            ),
            _buildTrendInfoChip(
              icon: Icons.show_chart_rounded,
              label: 'Rata-rata',
              value: '${_formatQuantity(averageDemand)} unit',
              color: AppColors.secondaryBlue,
            ),
            _buildTrendInfoChip(
              icon: Icons.trending_up_rounded,
              label: 'Tertinggi',
              value: '${_formatQuantity(maxDemand)} unit',
              color: AppColors.statusSuccess,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            RotatedBox(
              quarterTurns: 3,
              child: Text(
                'Jumlah permintaan (unit)',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (demandTrend.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY,
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: AppColors.grey200),
                        bottom: BorderSide(color: AppColors.grey200),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: yInterval,
                      getDrawingHorizontalLine:
                          (_) => FlLine(
                            color: AppColors.grey200.withValues(alpha: 0.7),
                            strokeWidth: 1,
                          ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: AppColors.textPrimary,
                        getTooltipItems:
                            (spots) =>
                                spots.map((spot) {
                                  return LineTooltipItem(
                                    'Prediksi ${spot.x.toInt() + 1}\n${_formatQuantity(spot.y)} unit',
                                    AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                }).toList(),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 34,
                          interval: yInterval,
                          getTitlesWidget: (value, meta) {
                            if (value < 0 || value > maxY) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              _formatQuantity(value),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            );
                          },
                        ),
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
                          interval: 1,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value % 1 != 0) {
                              return const SizedBox.shrink();
                            }
                            if (value < 0 || value >= demandTrend.length) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'P${value.toInt() + 1}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
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
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.secondaryBlue.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'P1-P${demandTrend.length} = urutan data prediksi dari paling lama ke paling baru',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChartState({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 32),
          const SizedBox(height: 10),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
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
                        color: AppColors.statusError.withValues(alpha: 0.12),
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

  Widget _buildExportActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _exportReport,
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _lastExportPath == null ? null : _openLastExport,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Buka File'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _lastExportPath == null ? null : _shareLastExport,
                icon: const Icon(Icons.share_outlined),
                label: const Text('Bagikan'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportReport() async {
    final period = await _selectExportPeriod();
    if (period == null) return;
    final format = await _selectExportFormat();
    if (format == null) return;

    if (_controller.stockItems.isEmpty &&
        _controller.stockHistory.isEmpty &&
        _controller.predictionItems.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data laporan masih kosong.')),
      );
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = _fileDateFormat.format(DateTime.now());
      final filePath =
          '${directory.path}${Platform.pathSeparator}'
          'laporan_${period.fileKey}_${format.fileKey}_$timestamp'
          '.${format.extension}';
      final file = File(filePath);

      if (format == ExportFormat.pdf) {
        await file.writeAsBytes(await _buildPdfContent(period));
      } else {
        await file.writeAsString('\ufeff${_buildCsvContent(period)}');
      }

      if (!mounted) return;
      setState(() => _lastExportPath = filePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Laporan ${format.label} telah diekspor'),
          action: SnackBarAction(
            label: 'Buka',
            onPressed: () {
              OpenFilex.open(filePath);
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal export laporan: $e')));
    }
  }

  Future<ExportPeriod?> _selectExportPeriod() {
    return showDialog<ExportPeriod>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Pilih Periode Export'),
          children:
              ExportPeriod.values.map((period) {
                return SimpleDialogOption(
                  onPressed: () => Navigator.of(context).pop(period),
                  child: Text(period.label),
                );
              }).toList(),
        );
      },
    );
  }

  Future<ExportFormat?> _selectExportFormat() {
    return showDialog<ExportFormat>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Pilih Format Export'),
          children:
              ExportFormat.values.map((format) {
                return SimpleDialogOption(
                  onPressed: () => Navigator.of(context).pop(format),
                  child: Text(format.label),
                );
              }).toList(),
        );
      },
    );
  }

  Future<void> _openLastExport() async {
    final path = _lastExportPath;
    if (path == null) return;

    final result = await OpenFilex.open(path);
    if (!mounted || result.type == ResultType.done) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal membuka file: ${result.message}')),
    );
  }

  Future<void> _shareLastExport() async {
    final path = _lastExportPath;
    if (path == null) return;

    await Share.shareXFiles(
      [XFile(path)],
      text: 'Laporan & Analitik',
      subject: 'Export Laporan',
    );
  }

  Future<List<int>> _buildPdfContent(ExportPeriod period) async {
    final now = DateTime.now();
    final startDate = _periodStartDate(period, now);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final stockHistory =
        _controller.stockHistory.where((entry) {
          return _isDateInRange(entry['date'] as DateTime, startDate, endDate);
        }).toList();
    final predictionItems =
        _controller.predictionItems.where((entry) {
          return _isDateInRange(entry['date'] as DateTime, startDate, endDate);
        }).toList();
    final stockItems = _sortedStockItems(_controller.stockItems);
    final stockSummary = _summarizeStockHistory(stockHistory);
    final predictionSummary = _summarizePredictions(predictionItems);

    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        footer: (context) {
          return pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          );
        },
        build: (context) {
          return [
            pw.Text(
              'LAPORAN & ANALITIK',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            _pdfSectionTitle('Informasi Laporan'),
            _pdfTable([
              ['Keterangan', 'Nilai'],
              ['Jenis Rekap', period.label],
              [
                'Periode',
                '${_dateFormat.format(startDate)} - ${_dateFormat.format(endDate)}',
              ],
              ['Tanggal Export', _dateFormat.format(now)],
            ]),
            _pdfSectionTitle('Ringkasan Laporan'),
            _pdfTable([
              ['Metrik', 'Nilai'],
              ['Total Produk', _controller.totalProduk.toString()],
              ['Total Bahan', _controller.totalBahan.toString()],
              ['Stok Kritis', _controller.totalKritis.toString()],
              ['Total Prediksi Periode', predictionItems.length.toString()],
              [
                'Total Transaksi Stok Masuk Periode',
                stockHistory.length.toString(),
              ],
            ]),
            _pdfSectionTitle('Stok Bahan Saat Ini'),
            _pdfTable([
              ['No', 'Nama Bahan', 'Stok', 'Unit', 'Status'],
              ...stockItems.asMap().entries.map((entry) {
                final item = entry.value;
                final stockValue = StockStatusUtils.parseStock(item['stock']);
                final statusKey = StockStatusUtils.statusFromStock(stockValue);
                return [
                  '${entry.key + 1}',
                  item['name']?.toString() ?? '-',
                  _formatQuantity(stockValue),
                  item['unit']?.toString() ?? 'kg',
                  StockStatusUtils.label(statusKey),
                ];
              }),
            ]),
            _pdfSectionTitle('Rekap Stok Masuk Periode'),
            _pdfTable([
              ['No', 'Nama Bahan', 'Total Jumlah', 'Unit'],
              if (stockSummary.isEmpty)
                ['-', 'Tidak ada data stok masuk pada periode ini', '-', '-']
              else
                ...stockSummary.asMap().entries.map((entry) {
                  final item = entry.value;
                  return [
                    '${entry.key + 1}',
                    item['name']?.toString() ?? '-',
                    _formatQuantity(item['amount']),
                    item['unit']?.toString() ?? 'kg',
                  ];
                }),
            ]),
            _pdfSectionTitle('Detail Riwayat Stok Masuk Periode'),
            _pdfTable([
              ['No', 'Tanggal', 'Nama Bahan', 'Jumlah', 'Unit'],
              if (stockHistory.isEmpty)
                ['-', 'Tidak ada data', '-', '-', '-']
              else
                ...stockHistory.asMap().entries.map((entry) {
                  final item = entry.value;
                  return [
                    '${entry.key + 1}',
                    _dateFormat.format(item['date'] as DateTime),
                    item['name']?.toString() ?? '-',
                    _formatQuantity(item['amount']),
                    item['unit']?.toString() ?? 'kg',
                  ];
                }),
            ]),
            _pdfSectionTitle('Rekap Prediksi Periode'),
            _pdfTable([
              ['No', 'Produk', 'Total Prediksi', 'Estimasi Kebutuhan Terakhir'],
              if (predictionSummary.isEmpty)
                ['-', 'Tidak ada data prediksi pada periode ini', '-', '-']
              else
                ...predictionSummary.asMap().entries.map((entry) {
                  final item = entry.value;
                  return [
                    '${entry.key + 1}',
                    item['product']?.toString() ?? '-',
                    _formatQuantity(item['prediction']),
                    item['needs']?.toString() ?? '-',
                  ];
                }),
            ]),
            _pdfSectionTitle('Detail Prediksi Permintaan Periode'),
            _pdfTable([
              ['No', 'Tanggal', 'Produk', 'Prediksi', 'Estimasi Kebutuhan'],
              if (predictionItems.isEmpty)
                ['-', 'Tidak ada data', '-', '-', '-']
              else
                ...predictionItems.asMap().entries.map((entry) {
                  final item = entry.value;
                  return [
                    '${entry.key + 1}',
                    _dateFormat.format(item['date'] as DateTime),
                    item['product']?.toString() ?? '-',
                    _formatQuantity(item['prediction']),
                    item['needs']?.toString() ?? '-',
                  ];
                }),
            ]),
          ];
        },
      ),
    );

    return document.save();
  }

  pw.Widget _pdfSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _pdfTable(List<List<String>> rows) {
    return pw.TableHelper.fromTextArray(
      data: rows,
      headerCount: 1,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    );
  }

  String _buildCsvContent(ExportPeriod period) {
    final now = DateTime.now();
    final startDate = _periodStartDate(period, now);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final stockHistory =
        _controller.stockHistory.where((entry) {
          return _isDateInRange(entry['date'] as DateTime, startDate, endDate);
        }).toList();
    final predictionItems =
        _controller.predictionItems.where((entry) {
          return _isDateInRange(entry['date'] as DateTime, startDate, endDate);
        }).toList();

    final buffer =
        StringBuffer()
          ..writeln('LAPORAN & ANALITIK')
          ..writeln('');

    _writeSection(buffer, 'Informasi Laporan');
    buffer
      ..writeln('Keterangan,Nilai')
      ..writeln('Jenis Rekap,${period.label}')
      ..writeln(
        'Periode,${_dateFormat.format(startDate)} - ${_dateFormat.format(endDate)}',
      )
      ..writeln('Tanggal Export,${_dateFormat.format(now)}')
      ..writeln('');

    _writeSection(buffer, 'Ringkasan Laporan');
    buffer
      ..writeln('Metrik,Nilai')
      ..writeln('Total Produk,${_controller.totalProduk}')
      ..writeln('Total Bahan,${_controller.totalBahan}')
      ..writeln('Stok Kritis,${_controller.totalKritis}')
      ..writeln('Total Prediksi Periode,${predictionItems.length}')
      ..writeln('Total Transaksi Stok Masuk Periode,${stockHistory.length}')
      ..writeln('');

    _writeSection(buffer, 'Stok Bahan Saat Ini');
    buffer.writeln('No,Nama Bahan,Stok,Unit,Status');
    final stockItems = _sortedStockItems(_controller.stockItems);
    for (var index = 0; index < stockItems.length; index++) {
      final item = stockItems[index];
      final stockValue = StockStatusUtils.parseStock(item['stock']);
      final statusKey = StockStatusUtils.statusFromStock(stockValue);
      final statusLabel = StockStatusUtils.label(statusKey);
      buffer.writeln(
        '${index + 1},${_escapeCsv(item['name'])},'
        '${_formatQuantity(stockValue)},'
        '${_escapeCsv(item['unit'])},$statusLabel',
      );
    }
    buffer.writeln('');

    _writeSection(buffer, 'Rekap Stok Masuk Periode');
    buffer.writeln('No,Nama Bahan,Total Jumlah,Unit');
    final stockSummary = _summarizeStockHistory(stockHistory);
    if (stockSummary.isEmpty) {
      buffer.writeln('-,Tidak ada data stok masuk pada periode ini,-,-');
    }
    for (var index = 0; index < stockSummary.length; index++) {
      final entry = stockSummary[index];
      buffer.writeln(
        '${index + 1},${_escapeCsv(entry['name'])},'
        '${_formatQuantity(entry['amount'])},'
        '${_escapeCsv(entry['unit'])}',
      );
    }
    buffer.writeln('');

    _writeSection(buffer, 'Detail Riwayat Stok Masuk Periode');
    buffer.writeln('No,Tanggal,Nama Bahan,Jumlah,Unit');
    if (stockHistory.isEmpty) {
      buffer.writeln('-,Tidak ada data,-,-,-');
    }
    for (var index = 0; index < stockHistory.length; index++) {
      final entry = stockHistory[index];
      final date = _dateFormat.format(entry['date'] as DateTime);
      buffer.writeln(
        '${index + 1},$date,${_escapeCsv(entry['name'])},'
        '${_formatQuantity(entry['amount'])},'
        '${_escapeCsv(entry['unit'])}',
      );
    }
    buffer.writeln('');

    _writeSection(buffer, 'Rekap Prediksi Periode');
    buffer.writeln('No,Produk,Total Prediksi,Estimasi Kebutuhan Terakhir');
    final predictionSummary = _summarizePredictions(predictionItems);
    if (predictionSummary.isEmpty) {
      buffer.writeln('-,Tidak ada data prediksi pada periode ini,-,-');
    }
    for (var index = 0; index < predictionSummary.length; index++) {
      final item = predictionSummary[index];
      buffer.writeln(
        '${index + 1},${_escapeCsv(item['product'])},'
        '${_formatQuantity(item['prediction'])},'
        '${_escapeCsv(item['needs'])}',
      );
    }
    buffer.writeln('');

    _writeSection(buffer, 'Detail Prediksi Permintaan Periode');
    buffer.writeln('No,Tanggal,Produk,Prediksi,Estimasi Kebutuhan');
    if (predictionItems.isEmpty) {
      buffer.writeln('-,Tidak ada data,-,-,-');
    }
    for (var index = 0; index < predictionItems.length; index++) {
      final item = predictionItems[index];
      final date = _dateFormat.format(item['date'] as DateTime);
      buffer.writeln(
        '${index + 1},$date,${_escapeCsv(item['product'])},'
        '${_formatQuantity(item['prediction'])},'
        '${_escapeCsv(item['needs'])}',
      );
    }
    buffer.writeln('');

    return buffer.toString();
  }

  void _writeSection(StringBuffer buffer, String title) {
    buffer
      ..writeln(title)
      ..writeln('---');
  }

  List<Map<String, dynamic>> _sortedStockItems(
    List<Map<String, dynamic>> items,
  ) {
    return items.toList()..sort((a, b) {
      final aStock = StockStatusUtils.parseStock(a['stock']);
      final bStock = StockStatusUtils.parseStock(b['stock']);
      final aStatus = StockStatusUtils.statusFromStock(aStock);
      final bStatus = StockStatusUtils.statusFromStock(bStock);
      final statusComparison = _statusOrder(
        aStatus,
      ).compareTo(_statusOrder(bStatus));
      if (statusComparison != 0) return statusComparison;
      return a['name'].toString().compareTo(b['name'].toString());
    });
  }

  int _statusOrder(String status) {
    switch (StockStatusUtils.normalizeStatus(status)) {
      case StockStatusUtils.statusKritis:
        return 0;
      case StockStatusUtils.statusSedang:
        return 1;
      case StockStatusUtils.statusTersedia:
      default:
        return 2;
    }
  }

  DateTime _periodStartDate(ExportPeriod period, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (period) {
      case ExportPeriod.daily:
        return today;
      case ExportPeriod.biweekly:
        return today.subtract(const Duration(days: 13));
      case ExportPeriod.monthly:
        return DateTime(now.year, now.month);
    }
  }

  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  List<Map<String, dynamic>> _summarizeStockHistory(
    List<Map<String, dynamic>> items,
  ) {
    final Map<String, Map<String, dynamic>> summary = {};
    for (final item in items) {
      final name = item['name']?.toString() ?? '-';
      final unit = item['unit']?.toString() ?? 'kg';
      final key = '$name|$unit';
      final current = summary[key];
      if (current == null) {
        summary[key] = {
          'name': name,
          'unit': unit,
          'amount': item['amount'] as double,
        };
      } else {
        current['amount'] = (current['amount'] as double) + item['amount'];
      }
    }

    return summary.values.toList()
      ..sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
  }

  List<Map<String, dynamic>> _summarizePredictions(
    List<Map<String, dynamic>> items,
  ) {
    final Map<String, Map<String, dynamic>> summary = {};
    for (final item in items) {
      final product = item['product']?.toString() ?? '-';
      final current = summary[product];
      if (current == null) {
        summary[product] = {
          'product': product,
          'prediction': item['prediction'] as double,
          'needs': item['needs'],
          'date': item['date'],
        };
      } else {
        current['prediction'] =
            (current['prediction'] as double) + item['prediction'];
        if ((item['date'] as DateTime).isAfter(current['date'] as DateTime)) {
          current['needs'] = item['needs'];
          current['date'] = item['date'];
        }
      }
    }

    return summary.values.toList()..sort(
      (a, b) => a['product'].toString().compareTo(b['product'].toString()),
    );
  }

  String _escapeCsv(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      final escaped = text.replaceAll('"', '""');
      return '"$escaped"';
    }
    return text;
  }

  String _formatQuantity(dynamic value) {
    final number = StockStatusUtils.parseStock(value);
    if (number % 1 == 0) return number.toInt().toString();
    return number.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
  }

  List<Map<String, dynamic>> _buildUsageBars(
    List<Map<String, dynamic>> usageSummary,
  ) {
    if (usageSummary.isEmpty) {
      return [];
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
        'unit': item['unit']?.toString() ?? 'kg',
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
    _stockTableScrollController.dispose();
    _stockHistoryScrollController.dispose();
    _predictionScrollController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
