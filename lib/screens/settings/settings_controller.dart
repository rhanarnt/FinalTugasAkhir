import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  int selectedIndex = 5;

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
