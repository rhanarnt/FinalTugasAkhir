import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  final usernameController = TextEditingController(text: 'admin@sulastri.com');
  final passwordController = TextEditingController(text: 'password');

  bool isPasswordVisible = false;
  bool isLoading = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  String? validateLoginForm() {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      return 'Email dan password tidak boleh kosong';
    }
    return null;
  }

  Future<bool> handleLogin() async {
    final error = validateLoginForm();
    if (error != null) return false;

    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    isLoading = false;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
