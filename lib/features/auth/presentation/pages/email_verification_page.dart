import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/main_app_bar.dart';
import '../../../../app/di.dart';

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
      setState(() {
        _verified = true;
        _isVerifying = false;
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Verifikacija nije uspela. Link je mozda istekao.';
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
      setState(() {
        _resent = true;
        _isResending = false;
      });
    } catch (e) {
      setState(() {
        _isResending = false;
        _errorMessage = 'Greska pri slanju emaila. Pokusajte ponovo.';
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
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isVerifying) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Verifikacija u toku...',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
          ),
        ],
      );
    }

    if (_verified) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_outlined, size: 64, color: AppColors.success),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Email verifikovan!',
            style: AppTypography.h3.copyWith(color: AppColors.foreground),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Vas email je uspesno verifikovan.',
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.email_outlined, size: 64, color: AppColors.primary),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Verifikacija emaila',
          style: AppTypography.h3.copyWith(color: AppColors.foreground),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Proverite sanducice za verifikacioni email.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
          textAlign: TextAlign.center,
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.destructive.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              _errorMessage!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.destructive),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        if (_resent) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              'Verifikacioni email ponovo poslat!',
              style: AppTypography.bodySmall.copyWith(color: AppColors.success),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton(
          onPressed: _isResending ? null : _resendVerification,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: _isResending
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Ponovo posalji verifikacioni email'),
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
