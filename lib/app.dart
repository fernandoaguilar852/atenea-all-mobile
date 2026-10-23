import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/config/theme_config.dart';
import 'core/config/env_config.dart';

class AteneaApp extends StatelessWidget {
  const AteneaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13 Pro size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'ATENEA POS',
          debugShowCheckedModeBanner: EnvConfig.debugShowCheckedModeBanner,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: child,
        );
      },
      child: const SplashScreen(),
    );
  }
}

// Splash Screen Temporal
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              // Logo
              Image.asset(
                'assets/images/atenea-logo.png',
                width: 200.w,
                height: 200.w,
              ),
              SizedBox(height: 24.h),

              // App Name
              Text(
                'ATENEA POS',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 8.h),

              // Tagline
              Text(
                'Sistema de Punto de Venta',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white.withOpacity(0.9),
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 48.h),

              // Loading Indicator
              SizedBox(
                width: 40.w,
                height: 40.w,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
