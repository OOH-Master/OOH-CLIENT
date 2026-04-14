import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../data/repository/profile_repository.dart';
import '../blocs/profile_bloc.dart';
import '../widgets/change_password_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(context.read<ProfileRepository>())
        ..add(LoadProfile()),
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
    final isDesktop = context.isDesktop;

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
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, dynamic>? profile;
        if (state is ProfileLoaded) {
          profile = state.profile;
          if (!_editMode) _populateControllers(profile);
        } else if (state is ProfileUpdateSuccess) {
          profile = state.profile;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? AppSpacing.lg : AppSpacing.md),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: isDesktop ? 700 : double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, l10n, profile),
                    const SizedBox(height: AppSpacing.lg),
                    // Personal Info Section
                    _buildSection(
                      title: 'Licni podaci',
                      icon: Icons.person_outline,
                      children: [
                        _buildFieldRow('Ime', _firstNameController),
                        _buildFieldRow('Prezime', _lastNameController),
                        _buildFieldRow('Email', _emailController),
                        _buildFieldRow('Telefon', _phoneController),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Organization Section
                    _buildSection(
                      title: 'Organizacija',
                      icon: Icons.business_outlined,
                      children: [
                        _buildFieldRow('Naziv kompanije', _companyNameController),
                        _buildFieldRow('Drzava', _countryController),
                        _buildFieldRow('Grad', _cityController),
                        _buildFieldRow('Veb sajt', _websiteController),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Account Section
                    _buildSection(
                      title: 'Nalog',
                      icon: Icons.settings_outlined,
                      children: [
                        _buildInfoRow('Korisnicko ime', profile?['username'] ?? ''),
                        _buildInfoRow('Uloga', profile?['role'] ?? ''),
                        _buildInfoRow(
                          'Email verifikovan',
                          (profile?['emailVerified'] == true) ? 'Da' : 'Ne',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: _showChangePasswordDialog,
                          icon: const Icon(Icons.lock_outline, size: 18),
                          label: const Text('Promeni lozinku'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Actions
                    if (_editMode) ...[
                      Row(
                        children: [
                          Expanded(
                            child: SecondaryButton(
                              text: 'Otkazi',
                              onPressed: () => setState(() => _editMode = false),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: PrimaryButton(
                              text: 'Sacuvaj',
                              onPressed: _onSave,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    // Logout
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
                        icon: Icon(Icons.logout, color: AppColors.destructive, size: 18),
                        label: Text(
                          l10n.logout,
                          style: TextStyle(color: AppColors.destructive),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.destructive.withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, Map<String, dynamic>? profile) {
    final name = profile?['username'] ?? '';
    final role = profile?['role'] ?? '';
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.primary,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: AppTypography.h2.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTypography.h4),
              Text(role, style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
            ],
          ),
        ),
        if (!_editMode)
          IconButton(
            onPressed: () => setState(() => _editMode = true),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Izmeni profil',
            color: AppColors.primary,
          ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(title, style: AppTypography.h6),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, TextEditingController controller) {
    if (_editMode) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: AppTextField(
          label: label,
          controller: controller,
        ),
      );
    }
    return _buildInfoRow(label, controller.text);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
