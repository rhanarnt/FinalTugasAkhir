import 'package:flutter/material.dart';
import 'package:finalproject/theme/app_theme.dart';
import 'package:finalproject/screens/splash_screen.dart';
import 'package:finalproject/screens/login_screen.dart';
import 'package:finalproject/screens/dashboard_screen.dart';
import 'package:finalproject/screens/prediction_screen.dart';
import 'package:finalproject/screens/transaction_screen.dart';
import 'package:finalproject/screens/product_list_screen.dart';
import 'package:finalproject/screens/report_screen.dart';
import 'package:finalproject/screens/settings_screen.dart';

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
