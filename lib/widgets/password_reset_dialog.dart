import 'package:finalproject/services/ml_service.dart';
import 'package:finalproject/theme/colors.dart';
import 'package:finalproject/theme/text_styles.dart';
import 'package:flutter/material.dart';

Future<bool> showPasswordResetDialog(
  BuildContext context, {
  String initialAccount = '',
  bool lockAccountField = false,
}) async {
  final accountController = TextEditingController(text: initialAccount.trim());
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int step = 0;
  bool isLoading = false;
  bool resetSuccess = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String? maskedEmail;

  void showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppColors.statusError : AppColors.primaryBrown,
      ),
    );
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> sendOtp() async {
            final account = accountController.text.trim();
            if (account.isEmpty) {
              showMessage('Email atau username wajib diisi', isError: true);
              return;
            }

            setDialogState(() => isLoading = true);
            final result = await MLService.sendForgotPasswordOtp(
              usernameOrEmail: account,
            );
            if (!context.mounted || !dialogContext.mounted) return;

            final success = result['status'] == 'success';
            setDialogState(() {
              isLoading = false;
              if (success) {
                step = 1;
                final data = result['data'];
                maskedEmail = data is Map ? data['email']?.toString() : null;
              }
            });

            showMessage(
              success
                  ? 'OTP berhasil dikirim ke email'
                  : result['message']?.toString() ?? 'Gagal membuat OTP',
              isError: !success,
            );
          }

          Future<void> resetPassword() async {
            final account = accountController.text.trim();
            final otp = otpController.text.trim();
            final newPassword = newPasswordController.text;
            final confirmPassword = confirmPasswordController.text;

            if (otp.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
              showMessage('OTP dan password baru wajib diisi', isError: true);
              return;
            }

            if (newPassword.length < 6) {
              showMessage('Password baru minimal 6 karakter', isError: true);
              return;
            }

            if (newPassword != confirmPassword) {
              showMessage('Konfirmasi password tidak sama', isError: true);
              return;
            }

            setDialogState(() => isLoading = true);
            final verifyResult = await MLService.verifyForgotPasswordOtp(
              usernameOrEmail: account,
              otp: otp,
            );
            if (!context.mounted || !dialogContext.mounted) return;

            if (verifyResult['status'] != 'success') {
              setDialogState(() => isLoading = false);
              showMessage(
                verifyResult['message']?.toString() ??
                    'OTP salah atau sudah kedaluwarsa',
                isError: true,
              );
              return;
            }

            final resetResult = await MLService.resetPasswordWithOtp(
              usernameOrEmail: account,
              otp: otp,
              newPassword: newPassword,
            );
            if (!context.mounted || !dialogContext.mounted) return;

            final success = resetResult['status'] == 'success';
            setDialogState(() => isLoading = false);

            showMessage(
              success
                  ? 'Password berhasil diperbarui.'
                  : resetResult['message']?.toString() ??
                      'Gagal reset password',
              isError: !success,
            );

            if (success) {
              resetSuccess = true;
              FocusScope.of(dialogContext).unfocus();
              Navigator.of(dialogContext).pop();
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              step == 0 ? 'Lupa Password' : 'Reset Password',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: accountController,
                    enabled: !isLoading && step == 0 && !lockAccountField,
                    decoration: const InputDecoration(
                      labelText: 'Email atau username',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  if (step == 1) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.grey300),
                      ),
                      child: Text(
                        maskedEmail == null
                            ? 'Kode OTP telah dikirim ke email akun Anda.'
                            : 'Kode OTP telah dikirim ke $maskedEmail.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: otpController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kode OTP',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPasswordController,
                      enabled: !isLoading,
                      obscureText: !isNewPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password baru',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip:
                              isNewPasswordVisible
                                  ? 'Sembunyikan password baru'
                                  : 'Tampilkan password baru',
                          icon: Icon(
                            isNewPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed:
                              isLoading
                                  ? null
                                  : () => setDialogState(
                                    () =>
                                        isNewPasswordVisible =
                                            !isNewPasswordVisible,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPasswordController,
                      enabled: !isLoading,
                      obscureText: !isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi password',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          tooltip:
                              isConfirmPasswordVisible
                                  ? 'Sembunyikan konfirmasi password'
                                  : 'Tampilkan konfirmasi password',
                          icon: Icon(
                            isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed:
                              isLoading
                                  ? null
                                  : () => setDialogState(
                                    () =>
                                        isConfirmPasswordVisible =
                                            !isConfirmPasswordVisible,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    isLoading ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : step == 0
                        ? sendOtp
                        : resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrown,
                  foregroundColor: Colors.white,
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(step == 0 ? 'Kirim OTP' : 'Simpan'),
              ),
            ],
          );
        },
      );
    },
  );

  await Future<void>.delayed(const Duration(milliseconds: 300));
  accountController.dispose();
  otpController.dispose();
  newPasswordController.dispose();
  confirmPasswordController.dispose();
  return resetSuccess;
}
