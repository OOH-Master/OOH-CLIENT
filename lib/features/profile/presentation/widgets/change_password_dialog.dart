import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';

class ChangePasswordDialog extends StatefulWidget {
  final void Function(String currentPassword, String newPassword) onSubmit;

  const ChangePasswordDialog({super.key, required this.onSubmit});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Promena lozinke',
        style: AppTypography.h5,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Trenutna lozinka',
              controller: _currentPasswordController,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              validator: (v) => (v == null || v.isEmpty) ? 'Obavezno polje' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Nova lozinka',
              controller: _newPasswordController,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Obavezno polje';
                if (v.length < 6) return 'Najmanje 6 karaktera';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Potvrdi novu lozinku',
              controller: _confirmPasswordController,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              validator: (v) {
                if (v != _newPasswordController.text) return 'Lozinke se ne poklapaju';
                return null;
              },
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
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(
                _currentPasswordController.text,
                _newPasswordController.text,
              );
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
          ),
          child: const Text('Promeni'),
        ),
      ],
    );
  }
}
