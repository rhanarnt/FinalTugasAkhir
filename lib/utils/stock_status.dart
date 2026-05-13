import 'package:finalproject/theme/colors.dart';
import 'package:flutter/material.dart';

class StockStatusUtils {
  StockStatusUtils._();

  static const double criticalStockLimitKg = 5;
  static const double warningStockLimitKg = 20;

  static const String statusTersedia = 'tersedia';
  static const String statusSedang = 'sedang';
  static const String statusKritis = 'kritis';

  static double parseStock(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static String statusFromStock(num stockKg) {
    final stock = stockKg.toDouble();
    if (stock < criticalStockLimitKg) return statusKritis;
    if (stock < warningStockLimitKg) return statusSedang;
    return statusTersedia;
  }

  static String normalizeStatus(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'rendah') return statusSedang;
    if (normalized == 'habis') return statusKritis;
    if (normalized == statusTersedia ||
        normalized == statusSedang ||
        normalized == statusKritis) {
      return normalized;
    }
    return statusKritis;
  }

  static String label(String status, {bool withIcon = false}) {
    switch (normalizeStatus(status)) {
      case statusTersedia:
        return withIcon ? '✅ Tersedia' : 'Tersedia';
      case statusSedang:
        return withIcon ? '⚠️ Sedang' : 'Sedang';
      case statusKritis:
      default:
        return withIcon ? '🔴 Kritis' : 'Kritis';
    }
  }

  static Color color(String status) {
    switch (normalizeStatus(status)) {
      case statusTersedia:
        return AppColors.statusSuccess;
      case statusSedang:
        return AppColors.statusWarning;
      case statusKritis:
      default:
        return AppColors.statusError;
    }
  }
}
