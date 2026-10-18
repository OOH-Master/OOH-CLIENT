import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../app/di.dart';
import '../widgets/auth_shell.dart';

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
      if (!mounted) return;
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Greška pri slanju emaila. Pokušajte ponovo.';
      });
    }
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthShell(
      art: AuthArt.bilbord,
      onBack: _back,
      child: _emailSent ? _buildSuccessView() : _buildFormView(l10n),
    );
  }

  Widget _buildSuccessView() {
    final email = _emailController.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthHeading(
          title: 'Proverite poštu',
          subtitle: email.isEmpty
              ? 'Poslali smo link za resetovanje lozinke. Link važi jedan sat.'
              : 'Ako postoji nalog sa adresom $email, na nju je poslat link za resetovanje lozinke. Link važi jedan sat.',
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => context.go('/auth/login'),
            child: const Text('Nazad na prijavu'),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _emailSent = false),
            child: const Text('Nije stiglo? Pošalji ponovo'),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthHeading(
          title: 'Zaboravljena lozinka',
          subtitle: 'Poslaćemo vam link za novu lozinku.',
        ),
        const SizedBox(height: 28),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthFieldLabel(l10n.emailLabel),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                onFieldSubmitted: (_) => _handleSubmit(),
                decoration: const InputDecoration(
                  hintText: 'ime@kompanija.rs',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
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
                const SizedBox(height: 14),
                AuthNotice(message: _errorMessage!),
              ],
              const SizedBox(height: 24),
              AuthSubmitButton(
                label: 'Pošalji link',
                loading: _isLoading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => context.go('/auth/login'),
            child: const Text('Nazad na prijavu'),
          ),
        ),
      ],
    );
  }
}
