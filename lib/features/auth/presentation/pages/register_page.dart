import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/main_app_bar.dart';
import '../../domain/entities/role.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/role_selector_card.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _orgFormKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Role
  Role _selectedRole = Role.brand;

  // Step 2: Account
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Step 3: Organization
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  static const _availableRoles = [Role.brand, Role.agency, Role.mediaOwner];
  static const _stepLabels = ['Uloga', 'Nalog', 'Organizacija'];

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _companyNameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  double _calcPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.2;
    if (password.length >= 8) strength += 0.1;
    if (password.length >= 12) strength += 0.1;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.15;
    return strength.clamp(0.0, 1.0);
  }

  Color _strengthColor(double strength) {
    if (strength < 0.3) return AppColors.destructive;
    if (strength < 0.6) return AppColors.warning;
    return AppColors.success;
  }

  String _strengthLabel(double strength) {
    if (strength < 0.3) return 'Slaba';
    if (strength < 0.6) return 'Srednja';
    return 'Jaka';
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (!_formKey.currentState!.validate()) return;
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onRegisterPressed() {
    if (!_orgFormKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      RegisterSubmitted(
        name: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        companyName: _companyNameController.text.trim(),
        phone: _phoneController.text.trim(),
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(showBackButton: true, showLoginButton: false),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            AppSnackbar.show(context, state.message, isError: true);
          }
        },
        child: isDesktop
            ? _buildDesktopLayout(l10n)
            : _buildMobileLayout(l10n),
      ),
    );
  }

  Widget _buildDesktopLayout(AppLocalizations l10n) {
    return Row(
      children: [
        // Left panel — branding
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.85),
                  const Color(0xFF4338CA),
                ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.apartment, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Kreirajte nalog',
                      style: AppTypography.displaySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pridružite se vodećoj platformi za\noutdoor oglašavanje u regionu.',
                      style: AppTypography.lead.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Step indicator on left panel
                    ...List.generate(3, (i) {
                      final isActive = i <= _currentStep;
                      final isComplete = i < _currentStep;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isComplete
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : isActive
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : Colors.white.withValues(alpha: 0.08),
                                border: Border.all(
                                  color: isActive
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Center(
                                child: isComplete
                                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                                    : Text(
                                        '${i + 1}',
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: isActive
                                              ? Colors.white
                                              : Colors.white.withValues(alpha: 0.5),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _stepLabels[i],
                              style: AppTypography.bodyLarge.copyWith(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Right panel — form
        Expanded(
          flex: 5,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: _buildFormContent(l10n),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.2, 1.0],
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            AppColors.background,
            AppColors.background,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: _buildFormContent(l10n),
      ),
    );
  }

  Widget _buildFormContent(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.authRegisterTitle,
            style: AppTypography.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Spacing.md),
          // Mobile step indicator
          _buildProgressIndicator(),
          const SizedBox(height: Spacing.lg),
          // Steps content
          SizedBox(
            height: _currentStep == 0 ? 380 : 420,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1RoleSelection(),
                _buildStep2AccountDetails(l10n),
                _buildStep3Organization(l10n),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          _buildNavigationButtons(l10n),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(_stepLabels.length, (index) {
        final isActive = index <= _currentStep;
        final isComplete = index < _currentStep;
        return Expanded(
          child: Row(
            children: [
              if (index > 0)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 2,
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.primary : AppColors.muted,
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: isComplete
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: AppTypography.labelMedium.copyWith(
                            color: isActive ? Colors.white : AppColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              if (index < _stepLabels.length - 1)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 2,
                    color: index < _currentStep ? AppColors.primary : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStep1RoleSelection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Izaberite tip naloga',
            style: AppTypography.h5.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Odaberite ulogu koja najbolje opisuje vasu delatnost.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(_availableRoles.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: RoleSelectorCard(
                role: _availableRoles[index],
                isSelected: _selectedRole == _availableRoles[index],
                onTap: () => setState(() => _selectedRole = _availableRoles[index]),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: (index * 80).ms).slideX(begin: 0.05);
          }),
        ],
      ),
    );
  }

  Widget _buildStep2AccountDetails(AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Podaci o nalogu',
              style: AppTypography.h5.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Unesite osnovne podatke za kreiranje naloga.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Ime',
                    controller: _firstNameController,
                    prefixIcon: Icons.person_outline,
                    validator: (v) => (v == null || v.isEmpty) ? l10n.validatorRequired : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppTextField(
                    label: 'Prezime',
                    controller: _lastNameController,
                    prefixIcon: Icons.person_outline,
                    validator: (v) => (v == null || v.isEmpty) ? l10n.validatorRequired : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: l10n.emailLabel,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.validatorEmailRequired;
                if (!v.contains('@')) return l10n.validatorEmailInvalid;
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: l10n.usernameLabel,
              controller: _usernameController,
              prefixIcon: Icons.alternate_email,
              validator: (v) => (v == null || v.isEmpty) ? l10n.validatorRequired : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: l10n.passwordLabel,
              controller: _passwordController,
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                  color: AppColors.mutedForeground,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.validatorPasswordRequired;
                if (v.length < 6) return l10n.validatorPasswordMin;
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            // Password strength indicator
            ValueListenableBuilder(
              valueListenable: _passwordController,
              builder: (_, value, ___) {
                final password = value.text;
                if (password.isEmpty) return const SizedBox.shrink();
                final strength = _calcPasswordStrength(password);
                final color = _strengthColor(strength);
                final label = _strengthLabel(strength);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      child: LinearProgressIndicator(
                        value: strength,
                        backgroundColor: AppColors.border,
                        color: color,
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Jacina lozinke: $label',
                      style: AppTypography.caption.copyWith(color: color),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3Organization(AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Form(
        key: _orgFormKey,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Podaci o organizaciji',
            style: AppTypography.h5.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Unesite podatke o vasoj kompaniji ili organizaciji.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Naziv kompanije',
            controller: _companyNameController,
            prefixIcon: Icons.business_outlined,
            validator: (v) => (v == null || v.isEmpty) ? l10n.validatorRequired : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: 'Telefon',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            validator: (v) => (v == null || v.isEmpty) ? l10n.validatorRequired : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: l10n.country,
            controller: _countryController,
            prefixIcon: Icons.flag_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: l10n.city,
            controller: _cityController,
            prefixIcon: Icons.location_city_outlined,
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(AppLocalizations l10n) {
    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _prevStep,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Nazad'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.foreground,
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: _currentStep < 2
              ? SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _nextStep,
                    icon: const Text('Dalje'),
                    label: const Icon(Icons.arrow_forward, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                )
              : BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading ? null : _onRegisterPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                          elevation: 0,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                l10n.registerButton,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
