import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../../app/di.dart';
import '../widgets/auth_shell.dart';

class EmailVerificationPage extends StatefulWidget {
  final String? token;

  const EmailVerificationPage({super.key, this.token});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isVerifying = false;
  bool _isResending = false;
  bool _verified = false;
  bool _resent = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.token != null && widget.token!.isNotEmpty) {
      _verifyEmail();
    }
  }

  Future<void> _verifyEmail() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      await getIt<ApiClient>().post(
        ApiConfig.authVerifyEmail,
        data: {'token': widget.token},
      );
      if (!mounted) return;
      setState(() {
        _verified = true;
        _isVerifying = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Potvrda nije uspela. Link je možda istekao.';
      });
    }
  }

  Future<void> _resendVerification() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      await getIt<ApiClient>().post(ApiConfig.authResendVerification);
      if (!mounted) return;
      setState(() {
        _resent = true;
        _isResending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _errorMessage = 'Greška pri slanju emaila. Pokušajte ponovo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      art: AuthArt.citylight,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isVerifying) {
      return Column(
        children: [
          const SizedBox(height: 24),
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 20),
          Text(
            'Proveravamo link za potvrdu…',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.mutedForeground),
          ),
        ],
      );
    }

    if (_verified) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthHeading(title: 'Email adresa je potvrđena'),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthHeading(
          title: 'Potvrdite email adresu',
          subtitle: 'Poslali smo vam poruku sa linkom za potvrdu.',
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 18),
          AuthNotice(message: _errorMessage!),
        ],
        if (_resent) ...[
          const SizedBox(height: 18),
          const AuthNotice(
            message: 'Poruka za potvrdu je ponovo poslata.',
            tone: PillTone.success,
          ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _isResending ? null : _resendVerification,
            icon: _isResending
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Pošalji link ponovo'),
          ),
        ),
        const SizedBox(height: 8),
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
