import 'package:finalproject/theme/colors.dart';
import 'package:flutter/material.dart';

class DashboardController extends ChangeNotifier {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> lowStockItems = [
    {
      'name': 'Tepung Terigu',
      'stock': '5 kg',
      'status': 'Kritis',
      'statusColor': AppColors.statusError,
    },
    {
      'name': 'Gula Pasir',
      'stock': '8 kg',
      'status': 'Rendah',
      'statusColor': AppColors.statusWarning,
    },
    {
      'name': 'Mentega',
      'stock': '3 kg',
      'status': 'Kritis',
      'statusColor': AppColors.statusError,
    },
  ];

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
