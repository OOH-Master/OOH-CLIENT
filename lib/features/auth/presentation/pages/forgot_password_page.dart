import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/main_app_bar.dart';
import '../../../../app/di.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await getIt<ApiClient>().post(
        ApiConfig.authForgotPassword,
        data: {'email': _emailController.text.trim()},
      );
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Greska pri slanju emaila. Pokusajte ponovo.';
      });
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
            child: _emailSent ? _buildSuccessView(l10n) : _buildFormView(l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.success),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Email poslat!',
          style: AppTypography.h3.copyWith(color: AppColors.foreground),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Proverite sanducice za link za resetovanje lozinke.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        TextButton(
          onPressed: () => context.go('/auth/login'),
          child: Text(
            'Nazad na prijavu',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Zaboravljena lozinka',
          style: AppTypography.h2.copyWith(color: AppColors.foreground),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Unesite email adresu i posalcemo vam link za resetovanje lozinke.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
                  decoration: InputDecoration(
                    labelText: l10n.emailLabel,
                    hintText: 'email@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validatorEmailRequired;
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return l10n.validatorEmailInvalid;
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _errorMessage!,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.destructive),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Posalji link za resetovanje',
                          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () => context.go('/auth/login'),
          child: Text(
            'Nazad na prijavu',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
