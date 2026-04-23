import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  int selectedIndex = 5;
  bool notificationEnabled = true;

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void setNotificationEnabled(bool value) {
    notificationEnabled = value;
    notifyListeners();
  }
}
