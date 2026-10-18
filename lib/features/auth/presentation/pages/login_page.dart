import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/auth_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/app/dashboard');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.destructive,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: AuthShell(
        art: AuthArt.ledSlavija,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeading(
              title: l10n.authLoginTitle,
              below: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.newHere,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.mutedForeground),
                  ),
                  _InlineLink(
                    label: l10n.createAccountLink,
                    onTap: () => context.go('/auth/register'),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms),
            const SizedBox(height: 28),
            _buildForm(l10n)
                .animate()
                .fadeIn(duration: 350.ms, delay: 80.ms)
                .slideY(begin: 0.03, curve: Curves.easeOut),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => context.go('/discover'),
                style: TextButton.styleFrom(foregroundColor: AppColors.text2),
                child: const Text('Istražite površine bez naloga'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthFieldLabel(l10n.usernameLabel),
              TextFormField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(
                  hintText: 'npr. citylight',
                  prefixIcon: Icon(Icons.person_outlined, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validatorRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              AuthFieldLabel(
                l10n.passwordLabel,
                trailing: _InlineLink(
                  label: 'Zaboravljena lozinka?',
                  onTap: () => context.push('/auth/forgot-password'),
                ),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                  suffixIcon: IconButton(
                    tooltip:
                        _obscurePassword ? 'Prikaži lozinku' : 'Sakrij lozinku',
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
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
              const SizedBox(height: 28),
              AuthSubmitButton(
                label: l10n.loginButton,
                loading: state is AuthLoading,
                onPressed: _handleLogin,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Veza u tekstu forme (bez okvira, indigo).
class _InlineLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _InlineLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
