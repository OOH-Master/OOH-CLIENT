import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/main_app_bar.dart';
import '../blocs/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginSubmitted(
              _usernameController.text.trim(),
              _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(showLoginButton: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Text(
                  'AutoHome',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Title
                Text(
                  l10n.authLoginTitle,
                  style: AppTypography.h1.copyWith(
                    color: AppColors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Subtitle with register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.newHere,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        l10n.createAccountLink,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthAuthenticated) {
                        context.go('/app/discover');
                      } else if (state is AuthFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Username Field
                            TextFormField(
                              controller: _usernameController,
                              keyboardType: TextInputType.text,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.foreground,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.emailLabel,
                                hintText: 'korisnicko_ime',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                prefixIcon: const Icon(Icons.person_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.validatorEmailRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.foreground,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.passwordLabel,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                prefixIcon: const Icon(Icons.lock_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.validatorPasswordRequired;
                                }
                                if (value.length < 6) {
                                  return l10n.validatorPasswordMin;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.push('/auth/forgot-password'),
                                child: Text(
                                  'Zaboravljena lozinka?',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Login Button
                            ElevatedButton(
                              onPressed: state is AuthLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.primaryForeground,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                              child: state is AuthLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      l10n.loginButton,
                                      style: AppTypography.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
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
