import 'package:flutter/material.dart';
import 'package:finalproject/theme/app_theme.dart';
import 'package:finalproject/screens/splash_screen.dart';
import 'package:finalproject/screens/login/login_page.dart';
import 'package:finalproject/screens/dashboard/dashboard_page.dart';
import 'package:finalproject/screens/prediction/prediction_page.dart';
import 'package:finalproject/screens/transaction/transaction_page.dart';
import 'package:finalproject/screens/products/product_list_page.dart';
import 'package:finalproject/screens/reports/report_page.dart';
import 'package:finalproject/screens/settings/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prediksi Stok Bahan Kue',
      theme: AppTheme.lightTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/prediction': (context) => const PredictionScreen(),
        '/transaction': (context) => const TransactionScreen(),
        '/products': (context) => const ProductListScreen(),
        '/reports': (context) => const ReportScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
