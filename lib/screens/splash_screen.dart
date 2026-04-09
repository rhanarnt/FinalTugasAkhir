import 'package:flutter/material.dart';
import 'package:finalproject/theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  String _statusMessage = 'Mempersiapkan aplikasi...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkApiHealth();
  }

  void _initializeAnimations() {
    // Fade animation untuk teks
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Scale animation untuk logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Rotate animation untuk loading circle
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleController.forward();
    _fadeController.forward();
    _rotateController.repeat();
  }

  Future<void> _checkApiHealth() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      setState(() => _statusMessage = 'Menghubungkan ke server...');

      // Simulate API check (uncomment MLService when needed)
      // final isHealthy = await MLService.healthCheck();

      // For now, always proceed to dashboard
      setState(() {
        _statusMessage = 'Siap!';
      });

      // Tunggu sebentar sebelum navigate
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Navigate ke Dashboard
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error: ${e.toString()}');
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Navigate ke Dashboard even on error
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.creamGradient.colors[0],
              AppColors.creamGradient.colors[1],
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern (subtle cake/bakery theme)
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: Image.network(
                  'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.transparent);
                  },
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top spacing
                  const Spacer(flex: 2),

                  // Center content
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo with scale animation
                          ScaleTransition(
                            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _scaleController,
                                curve: Curves.elasticOut,
                              ),
                            ),
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBrown,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '🍰',
                                  style: TextStyle(fontSize: 60),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // App name with fade-in
                          FadeTransition(
                            opacity: Tween<double>(begin: 0.0, end: 1.0)
                                .animate(
                              CurvedAnimation(
                                parent: _fadeController,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Main title
                                Text(
                                  'Sulastri',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBrown,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Subtitle
                                Text(
                                  'Toko Bahan Kue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryBrownDark,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Tagline with icon
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: AppColors.primaryBrownLight,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Smart Inventory Management',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textTertiary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom section with loading & version
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Loading dots animation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ScaleTransition(
                              scale: Tween<double>(begin: 0.4, end: 1.0)
                                  .animate(
                                CurvedAnimation(
                                  parent: _rotateController,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBrown,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ScaleTransition(
                              scale: Tween<double>(begin: 0.4, end: 1.0)
                                  .animate(
                                CurvedAnimation(
                                  parent: _rotateController,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBrown,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ScaleTransition(
                              scale: Tween<double>(begin: 0.4, end: 1.0)
                                  .animate(
                                CurvedAnimation(
                                  parent: _rotateController,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBrown,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Version text
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
