import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';

class UserEditDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final void Function(Map<String, dynamic> data) onSave;

  const UserEditDialog({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user['firstName'] ?? '');
    _lastNameController = TextEditingController(text: widget.user['lastName'] ?? '');
    _emailController = TextEditingController(text: widget.user['email'] ?? '');
    _companyNameController = TextEditingController(text: widget.user['companyName'] ?? '');
    _phoneController = TextEditingController(text: widget.user['phone'] ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.user['username'] ?? '';
    final role = widget.user['role'] ?? '';

    return AlertDialog(
      title: Text('Izmeni korisnika: $username', style: AppTypography.h5),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Uloga: $role', style: AppTypography.caption.copyWith(color: AppColors.mutedForeground)),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Ime',
              controller: _firstNameController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Prezime',
              controller: _lastNameController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Email',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Naziv kompanije',
              controller: _companyNameController,
              prefixIcon: Icons.business_outlined,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Telefon',
              controller: _phoneController,
              prefixIcon: Icons.phone_outlined,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Otkazi'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave({
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
              'email': _emailController.text.trim(),
              'companyName': _companyNameController.text.trim(),
              'phone': _phoneController.text.trim(),
            });
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
          ),
          child: const Text('Sacuvaj'),
        ),
      ],
    );
  }
}
