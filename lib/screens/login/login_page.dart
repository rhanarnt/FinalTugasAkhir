import 'package:finalproject/theme/colors.dart';
import 'package:finalproject/theme/text_styles.dart';
import 'package:flutter/material.dart';

import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
  }

  Future<void> _onLoginPressed() async {
    final validationError = _controller.validateLoginForm();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: AppColors.statusError,
        ),
      );
      return;
    }

    final success = await _controller.handleLogin();
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgLight,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.bgWhite,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [AppColors.shadowLight],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 32.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBrown,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.home_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Selamat Datang',
                                style: AppTextStyles.displaySmall.copyWith(
                                  color: AppColors.primaryBrown,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Masuk ke akun Anda',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Email atau Username',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _controller.usernameController,
                                enabled: !_controller.isLoading,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan email atau username',
                                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.grey300,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: AppColors.grey300,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.bgLight,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Password',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _controller.passwordController,
                                enabled: !_controller.isLoading,
                                obscureText: !_controller.isPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan password',
                                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.grey300,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: AppColors.textSecondary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _controller.isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed:
                                        _controller.isLoading
                                            ? null
                                            : _controller
                                                .togglePasswordVisibility,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: AppColors.grey300,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.bgLight,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed:
                                      _controller.isLoading ? null : () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(
                                    'Lupa Password?',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.primaryBrown,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _controller.isLoading
                                          ? null
                                          : _onLoginPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBrown,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child:
                                      _controller.isLoading
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : Text(
                                            'Masuk',
                                            style: AppTextStyles.labelLarge
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.bgLight,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.grey300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Demo: Klik "Masuk" untuk melanjutkan',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.statusError,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        '© 2025 Toko Bahan Kue Sulastri',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
