import 'package:flutter/material.dart';

class ReportController extends ChangeNotifier {
  String selectedPeriod = 'bulanan';

  final List<String> periods = ['harian', 'mingguan', 'bulanan', 'tahunan'];
  final List<(String, int)> topProducts = const [
    ('Tepung Terigu', 25),
    ('Gula Pasir', 18),
    ('Telur', 15),
    ('Mentega', 12),
    ('Cokelat Bubuk', 10),
  ];

  void setSelectedPeriod(String value) {
    selectedPeriod = value;
    notifyListeners();
  }

  String capitalize(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';
}
