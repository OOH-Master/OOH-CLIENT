import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../data/repository/profile_repository.dart';
import '../blocs/profile_bloc.dart';
import '../widgets/change_password_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(context.read<ProfileRepository>())..add(LoadProfile()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  bool _editMode = false;

  /// Poslednji učitani profil; ostaje na ekranu i dok traje čuvanje ili
  /// promena lozinke.
  Map<String, dynamic>? _profile;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _populateControllers(Map<String, dynamic> profile) {
    _firstNameController.text = profile['firstName'] ?? '';
    _lastNameController.text = profile['lastName'] ?? '';
    _emailController.text = profile['email'] ?? '';
    _phoneController.text = profile['phone'] ?? '';
    _companyNameController.text = profile['companyName'] ?? '';
    _countryController.text = profile['country'] ?? '';
    _cityController.text = profile['city'] ?? '';
    _websiteController.text = profile['website'] ?? '';
  }

  void _onSave() {
    context.read<ProfileBloc>().add(UpdateProfile({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'companyName': _companyNameController.text.trim(),
          'country': _countryController.text.trim(),
          'city': _cityController.text.trim(),
          'website': _websiteController.text.trim(),
        }));
    setState(() => _editMode = false);
  }

  void _onCancel() {
    if (_profile != null) _populateControllers(_profile!);
    setState(() => _editMode = false);
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => ChangePasswordDialog(
        onSubmit: (current, newPass) {
          context.read<ProfileBloc>().add(
                ChangePassword(currentPassword: current, newPassword: newPass),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          AppSnackbar.show(context, state.message);
        } else if (state is PasswordChangeSuccess) {
          AppSnackbar.show(context, state.message);
        } else if (state is ProfileError) {
          AppSnackbar.show(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        if (state is ProfileLoaded) {
          _profile = state.profile;
          if (!_editMode) _populateControllers(state.profile);
        } else if (state is ProfileUpdateSuccess) {
          _profile = state.profile;
        }
        final profile = _profile;
        final busy = state is ProfileLoading || state is ProfileInitial;

        if (profile == null) {
          if (state is ProfileError) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: EmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'Profil trenutno nije dostupan',
                message: state.message,
                action: OutlinedButton.icon(
                  onPressed: () =>
                      context.read<ProfileBloc>().add(LoadProfile()),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.retry),
                ),
              ),
            );
          }
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final side = wide ? 32.0 : 16.0;
                  final gutter =
                      math.max(side, (constraints.maxWidth - 1240) / 2);
                  final contentWidth = constraints.maxWidth - 2 * gutter;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(wide),
                        _buildBody(profile, contentWidth, l10n),
                      ],
                    ),
                  );
                },
              ),
              if (busy)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool wide) {
    return PageHeader(
      title: 'Profil',
      padding: wide
          ? const EdgeInsets.only(top: 28, bottom: 22)
          : const EdgeInsets.only(top: 18, bottom: 14),
      actions: _editMode
          ? [
              TextButton(onPressed: _onCancel, child: const Text('Otkaži')),
              FilledButton.icon(
                onPressed: _onSave,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('Sačuvaj'),
              ),
            ]
          : [
              OutlinedButton.icon(
                onPressed: () => setState(() => _editMode = true),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Izmeni profil'),
              ),
            ],
    );
  }

  Widget _buildBody(
      Map<String, dynamic> profile, double width, AppLocalizations l10n) {
    final identity = _IdentityCard(
      profile: profile,
      onChangePassword: _showChangePasswordDialog,
      onLogout: () => context.read<AuthBloc>().add(LogoutRequested()),
      logoutLabel: l10n.logout,
    );

    final personal = SectionCard(
      title: 'Lični podaci',
      child: _FieldGrid(children: [
        _field('Ime', _firstNameController),
        _field('Prezime', _lastNameController),
        _field('Email', _emailController,
            readOnly: true, helper: 'Ne menja se ovde.'),
        _field('Telefon', _phoneController, keyboard: TextInputType.phone),
      ]),
    );

    final organization = SectionCard(
      title: 'Organizacija',
      child: _FieldGrid(children: [
        _field('Naziv kompanije', _companyNameController),
        _field('Veb sajt', _websiteController, keyboard: TextInputType.url),
        _field('Država', _countryController),
        _field('Grad', _cityController),
      ]),
    );

    if (width >= 880) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 320, child: identity),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [personal, const SizedBox(height: 16), organization],
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        identity,
        const SizedBox(height: 16),
        personal,
        const SizedBox(height: 16),
        organization,
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    String? helper,
    TextInputType? keyboard,
  }) {
    if (_editMode) {
      return TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          helperText: readOnly ? helper : null,
          helperMaxLines: 2,
          filled: true,
          fillColor: readOnly ? AppColors.surfaceSunken : AppColors.surface,
        ),
      );
    }
    return _InfoField(label: label, value: controller.text);
  }
}

/// Polja u dve kolone kada ima mesta.
class _FieldGrid extends StatelessWidget {
  final List<Widget> children;

  const _FieldGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final two = constraints.maxWidth >= 520;
        final w = two ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [for (final c in children) SizedBox(width: w, child: c)],
        );
      },
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final empty = value.trim().isEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.caption
                  .copyWith(color: AppColors.mutedForeground)),
          const SizedBox(height: 2),
          Text(
            empty ? 'Nije uneto' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: empty
                ? AppTypography.bodyMedium.copyWith(color: AppColors.subtle)
                : AppTypography.labelLarge,
          ),
        ],
      ),
    );
  }
}

/// Kartica identiteta: avatar, naziv, uloga, kontakt i akcije naloga.
class _IdentityCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;
  final String logoutLabel;

  const _IdentityCard({
    required this.profile,
    required this.onChangePassword,
    required this.onLogout,
    required this.logoutLabel,
  });

  String _s(String key) => (profile[key] as String?)?.trim() ?? '';

  @override
  Widget build(BuildContext context) {
    final username = _s('username');
    final company = _s('companyName');
    final person = '${_s('firstName')} ${_s('lastName')}'.trim();
    final name =
        company.isNotEmpty ? company : (person.isNotEmpty ? person : username);
    final verified = profile['emailVerified'] == true;
    final place = SrLabels.place(_s('city'), _s('country'));

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(name: name.isEmpty ? '?' : name, size: 64),
          const SizedBox(height: 14),
          Text(name.isEmpty ? '—' : name, style: AppTypography.h4),
          if (company.isNotEmpty && person.isNotEmpty)
            Text(
              person,
              style: AppTypography.bodySmall.copyWith(color: AppColors.text2),
            ),
          if (username.isNotEmpty)
            Text(
              '@$username',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.mutedForeground),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusPill(
                label: SrLabels.role(profile['role'] as String?),
                tone: PillTone.primary,
              ),
              StatusPill(
                label: verified ? 'Email potvrđen' : 'Email nije potvrđen',
                tone: verified ? PillTone.success : PillTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          _ContactLine(_s('email')),
          _ContactLine(_s('phone')),
          _ContactLine(place),
          _ContactLine(_s('website')),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onChangePassword,
              icon: const Icon(Icons.lock_outline_rounded, size: 18),
              label: const Text('Promeni lozinku'),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text(logoutLabel),
              style:
                  TextButton.styleFrom(foregroundColor: AppColors.destructive),
            ),
          ),
        ],
      ),
    );
  }
}

/// Jedan kontakt podatak (email, telefon, mesto, veb sajt) kao red teksta.
class _ContactLine extends StatelessWidget {
  final String value;

  const _ContactLine(this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySmall.copyWith(color: AppColors.text2),
      ),
    );
  }
}
