import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../app/di.dart';
import '../widgets/auth_shell.dart';

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
  bool _obscure = true;
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
      case 1:
        return AppColors.destructive;
      case 2:
        return AppColors.primary;
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
      if (!mounted) return;
      setState(() {
        _resetSuccess = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Greška pri resetovanju lozinke. Link je možda istekao.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      art: AuthArt.bilbord,
      child: _resetSuccess ? _buildSuccessView() : _buildFormView(),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeading(title: 'Lozinka je promenjena'),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => context.go('/auth/login'),
            child: const Text('Prijavi se'),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    final l10n = AppLocalizations.of(context)!;

    final toggle = IconButton(
      tooltip: _obscure ? 'Prikaži lozinku' : 'Sakrij lozinku',
      icon: Icon(
        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
      ),
      onPressed: () => setState(() => _obscure = !_obscure),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthHeading(
          title: 'Postavite novu lozinku',
          subtitle: 'Najmanje 8 karaktera.',
        ),
        if (widget.token.isEmpty) ...[
          const SizedBox(height: 18),
          const AuthNotice(
            message:
                'Link ne sadrži oznaku za resetovanje. Otvorite link iz poruke ili zatražite novi.',
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.go('/auth/forgot-password'),
              child: const Text('Zatraži novi link'),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthFieldLabel('Nova lozinka'),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: toggle,
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: _passwordStrength / 4,
                          minHeight: 5,
                          backgroundColor: AppColors.surfaceSunken,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_strengthColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _strengthLabel,
                      style: AppTypography.caption.copyWith(
                          color: _strengthColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              const AuthFieldLabel('Potvrdite lozinku'),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleSubmit(),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Lozinke se ne poklapaju';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                AuthNotice(message: _errorMessage!),
              ],
              const SizedBox(height: 24),
              AuthSubmitButton(
                label: 'Sačuvaj novu lozinku',
                loading: _isLoading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
