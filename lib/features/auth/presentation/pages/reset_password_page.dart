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

class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({super.key, required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _resetSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int get _passwordStrength {
    final password = _passwordController.text;
    if (password.isEmpty) return 0;
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 0:
        return AppColors.mutedForeground;
      case 1:
        return AppColors.destructive;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.info;
      case 4:
        return AppColors.success;
      default:
        return AppColors.mutedForeground;
    }
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 0:
        return '';
      case 1:
        return 'Slaba';
      case 2:
        return 'Srednja';
      case 3:
        return 'Dobra';
      case 4:
        return 'Jaka';
      default:
        return '';
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await getIt<ApiClient>().post(
        ApiConfig.authResetPassword,
        data: {
          'token': widget.token,
          'newPassword': _passwordController.text,
        },
      );
      setState(() {
        _resetSuccess = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Greska pri resetovanju lozinke. Link je mozda istekao.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(showLoginButton: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _resetSuccess ? _buildSuccessView() : _buildFormView(),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Lozinka resetovana!',
          style: AppTypography.h3.copyWith(color: AppColors.foreground),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Mozete se prijaviti sa novom lozinkom.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton(
          onPressed: () => context.go('/auth/login'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: Text('Prijavi se', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Resetovanje lozinke',
          style: AppTypography.h2.copyWith(color: AppColors.foreground),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Unesite novu lozinku.',
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
                  controller: _passwordController,
                  obscureText: true,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Nova lozinka',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    prefixIcon: const Icon(Icons.lock_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.validatorPasswordRequired;
                    }
                    if (value.length < 8) {
                      return 'Lozinka mora imati najmanje 8 karaktera';
                    }
                    return null;
                  },
                ),
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _passwordStrength / 4,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _strengthLabel,
                        style: AppTypography.caption.copyWith(color: _strengthColor),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
                  decoration: InputDecoration(
                    labelText: 'Potvrdi lozinku',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    prefixIcon: const Icon(Icons.lock_outlined),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Lozinke se ne poklapaju';
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
                          'Resetuj lozinku',
                          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
