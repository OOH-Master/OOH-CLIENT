import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/main_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing.dart';
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
  double _passwordStrength = 0;

  // Step 3: Organization
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  static const _availableRoles = [Role.brand, Role.agency, Role.mediaOwner];

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

  void _updatePasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.2;
    if (password.length >= 8) strength += 0.1;
    if (password.length >= 12) strength += 0.1;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.15;
    setState(() => _passwordStrength = strength.clamp(0.0, 1.0));
  }

  Color get _strengthColor {
    if (_passwordStrength < 0.3) return AppColors.destructive;
    if (_passwordStrength < 0.6) return AppColors.warning;
    return AppColors.success;
  }

  String get _strengthLabel {
    if (_passwordStrength < 0.3) return 'Slaba';
    if (_passwordStrength < 0.6) return 'Srednja';
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
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(showBackButton: true, showLoginButton: false),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            AppSnackbar.show(context, state.message, isError: true);
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Container(
              constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.authRegisterTitle,
                        style: AppTypography.h4,
                      ),
                      const SizedBox(height: Spacing.md),
                      // Progress indicator
                      _buildProgressIndicator(),
                      const SizedBox(height: Spacing.lg),
                      // Steps
                      SizedBox(
                        height: _currentStep == 0 ? 420 : 360,
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
                      // Navigation buttons
                      _buildNavigationButtons(l10n),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Uloga', 'Nalog', 'Organizacija'];
    return Row(
      children: List.generate(steps.length, (index) {
        final isActive = index <= _currentStep;
        final isComplete = index < _currentStep;
        return Expanded(
          child: Row(
            children: [
              if (index > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.primary : AppColors.muted,
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
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
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
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
            style: AppTypography.h5,
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
            );
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
            Text('Podaci o nalogu', style: AppTypography.h5),
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
              obscureText: true,
              prefixIcon: Icons.lock_outline,
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
              builder: (_, __, ___) {
                _updatePasswordStrength(_passwordController.text);
                if (_passwordController.text.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      child: LinearProgressIndicator(
                        value: _passwordStrength,
                        backgroundColor: AppColors.border,
                        color: _strengthColor,
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Jacina lozinke: $_strengthLabel',
                      style: AppTypography.caption.copyWith(color: _strengthColor),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Podaci o organizaciji', style: AppTypography.h5),
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
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: 'Telefon',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
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
    );
  }

  Widget _buildNavigationButtons(AppLocalizations l10n) {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: SecondaryButton(
              text: 'Nazad',
              onPressed: _prevStep,
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _currentStep < 2
              ? PrimaryButton(
                  text: 'Dalje',
                  onPressed: _nextStep,
                )
              : BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      text: l10n.registerButton,
                      onPressed: _onRegisterPressed,
                      isLoading: state is AuthLoading,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
