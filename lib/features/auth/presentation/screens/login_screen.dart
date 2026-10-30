import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/services/credentials_storage_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _credentialsService = CredentialsStorageService();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoadingCredentials = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    setState(() => _isLoadingCredentials = true);

    try {
      final hasCredentials = await _credentialsService.hasCredentials();
      if (hasCredentials) {
        final credentials = await _credentialsService.getCredentials();
        if (credentials != null && mounted) {
          setState(() {
            _emailController.text = credentials.email;
            _passwordController.text = credentials.password;
            _rememberMe = true;
          });
        }
      }
    } catch (e) {
      // Si falla la autenticación biométrica, simplemente no pre-llena
    } finally {
      if (mounted) {
        setState(() => _isLoadingCredentials = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      await ref.read(authProvider.notifier).login(email, password);

      // Guardar credenciales si el usuario marcó "Recordar"
      await _credentialsService.saveCredentials(
        email: email,
        password: password,
        rememberMe: _rememberMe,
      );

      if (mounted) {
        // Navigation will be handled by router
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inicio de sesión exitoso'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Mostrar loading mientras carga las credenciales
    if (_isLoadingCredentials) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpacing.xxl),

                // Logo - Más grande y con más espacio
                Center(
                  child: Image.asset(
                    'assets/images/atenea-logo.png',
                    width: 180.w,
                    height: 180.w,
                  ),
                ),

                SizedBox(height: AppSpacing.xl),

                // Title - Más grande y moderno con Inter
                Text(
                  'ATENEA POS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'Inter',
                    height: 1.2,
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

                // Subtitle - Con Inter
                Text(
                  'Sistema de Punto de Venta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                ),

                SizedBox(height: AppSpacing.xxl),

                // Email Field
                AppTextField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  hint: 'ejemplo@correo.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El correo es requerido';
                    }
                    if (!value.contains('@')) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),

                SizedBox(height: AppSpacing.md),

                // Password Field
                AppTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La contraseña es requerida';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),

                SizedBox(height: AppSpacing.sm),

                // Remember Me Checkbox
                Row(
                  children: [
                    SizedBox(
                      height: 24.h,
                      width: 24.w,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Recordar mis datos',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to forgot password
                      },
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.lg),

                // Login Button
                AppButton(
                  text: 'Iniciar Sesión',
                  onPressed: _handleLogin,
                  isLoading: authState.isLoading,
                ),

                SizedBox(height: AppSpacing.lg),

                // Error Message - Flat design con border sutil
                if (authState.error != null)
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.danger,
                          size: 20.sp,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: 13.sp,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
