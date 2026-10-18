import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/role.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/auth_shell.dart';
import '../widgets/role_selector_card.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _orgFormKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Korak 1: uloga
  Role _selectedRole = Role.brand;

  // Korak 2: nalog
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Korak 3: organizacija
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  static const _availableRoles = [Role.brand, Role.agency, Role.mediaOwner];
  static const _stepLabels = ['Uloga', 'Nalog', 'Organizacija'];

  @override
  void dispose() {
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
    if (strength < 0.6) return AppColors.primary;
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
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
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

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final Widget step = switch (_currentStep) {
      0 => _buildStep1RoleSelection(),
      1 => _buildStep2AccountDetails(l10n),
      _ => _buildStep3Organization(l10n),
    };

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          AppSnackbar.show(context, state.message, isError: true);
        }
      },
      child: AuthShell(
        art: AuthArt.citylight,
        onBack: _leave,
        maxFormWidth: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeading(
              title: l10n.authRegisterTitle,
              below: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Već imate nalog?',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.mutedForeground),
                  ),
                  TextButton(
                    onPressed: () => context.go('/auth/login'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Prijavite se',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _StepIndicator(current: _currentStep, labels: _stepLabels),
            const SizedBox(height: 28),
            // Samo trenutni korak je u stablu, pa se ključevi formi ne ponavljaju.
            KeyedSubtree(
              key: ValueKey(_currentStep),
              child: step
                  .animate()
                  .fadeIn(duration: 220.ms)
                  .slideX(begin: 0.03, curve: Curves.easeOut),
            ),
            const SizedBox(height: 28),
            _buildNavigationButtons(l10n),
          ],
        ),
      ),
    );
  }

  Widget _stepTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Text(title, style: AppTypography.h5),
    );
  }

  Widget _buildStep1RoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepTitle('Ko ste vi na platformi?'),
        for (final role in _availableRoles)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RoleSelectorCard(
              role: role,
              isSelected: _selectedRole == role,
              onTap: () => setState(() => _selectedRole = role),
            ),
          ),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    Iterable<String>? autofill,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthFieldLabel(label),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            textInputAction: TextInputAction.next,
            autofillHints: autofill,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              suffixIcon: suffix,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  /// Dva polja jedno pored drugog kada ima mesta, inače jedno ispod drugog.
  Widget _pair(Widget a, Widget b) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(children: [a, b]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: a),
            const SizedBox(width: 12),
            Expanded(child: b),
          ],
        );
      },
    );
  }

  Widget _buildStep2AccountDetails(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepTitle('Podaci o nalogu'),
          _pair(
            _field(
              label: 'Ime',
              controller: _firstNameController,
              icon: Icons.badge_outlined,
              autofill: const [AutofillHints.givenName],
              validator: (v) =>
                  (v == null || v.isEmpty) ? l10n.validatorRequired : null,
            ),
            _field(
              label: 'Prezime',
              controller: _lastNameController,
              icon: Icons.badge_outlined,
              autofill: const [AutofillHints.familyName],
              validator: (v) =>
                  (v == null || v.isEmpty) ? l10n.validatorRequired : null,
            ),
          ),
          _field(
            label: l10n.emailLabel,
            controller: _emailController,
            icon: Icons.email_outlined,
            hint: 'ime@kompanija.rs',
            keyboardType: TextInputType.emailAddress,
            autofill: const [AutofillHints.email],
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.validatorEmailRequired;
              if (!v.contains('@')) return l10n.validatorEmailInvalid;
              return null;
            },
          ),
          _field(
            label: l10n.usernameLabel,
            controller: _usernameController,
            icon: Icons.alternate_email_rounded,
            hint: 'koristi se za prijavu',
            autofill: const [AutofillHints.newUsername],
            validator: (v) =>
                (v == null || v.isEmpty) ? l10n.validatorRequired : null,
          ),
          _field(
            label: l10n.passwordLabel,
            controller: _passwordController,
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            autofill: const [AutofillHints.newPassword],
            suffix: IconButton(
              tooltip: _obscurePassword ? 'Prikaži lozinku' : 'Sakrij lozinku',
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.validatorPasswordRequired;
              if (v.length < 6) return l10n.validatorPasswordMin;
              return null;
            },
          ),
          ValueListenableBuilder(
            valueListenable: _passwordController,
            builder: (_, value, __) {
              final password = value.text;
              if (password.isEmpty) return const SizedBox.shrink();
              final strength = _calcPasswordStrength(password);
              final color = _strengthColor(strength);
              return Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: strength,
                        backgroundColor: AppColors.surfaceSunken,
                        color: color,
                        minHeight: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Jačina lozinke: ${_strengthLabel(strength)}',
                    style: AppTypography.caption
                        .copyWith(color: color, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Organization(AppLocalizations l10n) {
    return Form(
      key: _orgFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepTitle('Podaci o organizaciji'),
          _field(
            label: 'Naziv kompanije',
            controller: _companyNameController,
            icon: Icons.business_outlined,
            autofill: const [AutofillHints.organizationName],
            validator: (v) =>
                (v == null || v.isEmpty) ? l10n.validatorRequired : null,
          ),
          _field(
            label: 'Telefon',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            hint: '+381 ...',
            keyboardType: TextInputType.phone,
            autofill: const [AutofillHints.telephoneNumber],
            validator: (v) =>
                (v == null || v.isEmpty) ? l10n.validatorRequired : null,
          ),
          _pair(
            _field(
              label: l10n.country,
              controller: _countryController,
              icon: Icons.flag_outlined,
              hint: 'Srbija',
              autofill: const [AutofillHints.countryName],
            ),
            _field(
              label: l10n.city,
              controller: _cityController,
              icon: Icons.location_city_outlined,
              hint: 'Beograd',
              autofill: const [AutofillHints.addressCity],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(AppLocalizations l10n) {
    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _prevStep,
                child: const Text('Nazad'),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: _currentStep > 0 ? 2 : 1,
          child: _currentStep < 2
              ? SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    child: const Text('Dalje'),
                  ),
                )
              : BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => AuthSubmitButton(
                    label: l10n.registerButton,
                    loading: state is AuthLoading,
                    onPressed: _onRegisterPressed,
                  ),
                ),
        ),
      ],
    );
  }
}

/// Tri koraka registracije: krug sa brojem (ili kvačicom) i naziv, spojeni linijom.
class _StepIndicator extends StatelessWidget {
  final int current;
  final List<String> labels;

  const _StepIndicator({required this.current, required this.labels});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      final done = i < current;
      final active = i == current;
      if (i > 0) {
        items.add(
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: i <= current ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        );
      }
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done || active ? AppColors.primary : AppColors.surface,
                border: Border.all(
                  color: done || active ? AppColors.primary : AppColors.input,
                  width: 1.5,
                ),
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : Text(
                      '${i + 1}',
                      style: AppTypography.labelMedium.copyWith(
                        color:
                            active ? Colors.white : AppColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Text(
              labels[i],
              style: AppTypography.labelMedium.copyWith(
                color: active || done
                    ? AppColors.foreground
                    : AppColors.mutedForeground,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return Row(children: items);
  }
}
