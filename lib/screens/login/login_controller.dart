import 'package:flutter/material.dart';
import 'package:finalproject/services/auth_service.dart';
import 'package:finalproject/services/ml_service.dart';

class LoginController extends ChangeNotifier {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;
  String? errorMessage;

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
    errorMessage = null;
    notifyListeners();

    final result = await MLService.login(
      usernameOrEmail: usernameController.text.trim(),
      password: passwordController.text,
    );

    isLoading = false;
    final success = result['status'] == 'success';
    if (success) {
      final data = result['data'];
      await AuthService.saveLoginSession(
        name: data is Map ? data['name']?.toString() : null,
        email: data is Map ? data['email']?.toString() : null,
      );
    } else {
      errorMessage = result['message']?.toString() ?? 'Login gagal';
    }
    notifyListeners();
    return success;
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
