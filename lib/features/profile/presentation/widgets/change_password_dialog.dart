import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

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
  bool _obscure = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      Navigator.pop(context);
    }
  }

  Widget _field(String label, TextEditingController controller,
      String? Function(String?) validator,
      {TextInputAction action = TextInputAction.next}) {
    return TextFormField(
      controller: controller,
      obscureText: _obscure,
      textInputAction: action,
      onFieldSubmitted:
          action == TextInputAction.done ? (_) => _submit() : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Promena lozinke'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field('Trenutna lozinka', _currentPasswordController,
                  (v) => (v == null || v.isEmpty) ? 'Obavezno polje' : null),
              const SizedBox(height: 14),
              _field('Nova lozinka', _newPasswordController, (v) {
                if (v == null || v.isEmpty) return 'Obavezno polje';
                if (v.length < 6) return 'Najmanje 6 karaktera';
                return null;
              }),
              const SizedBox(height: 14),
              _field(
                'Potvrdite novu lozinku',
                _confirmPasswordController,
                (v) {
                  if (v != _newPasswordController.text) {
                    return 'Lozinke se ne poklapaju';
                  }
                  return null;
                },
                action: TextInputAction.done,
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                  ),
                  label: Text(_obscure ? 'Prikaži lozinke' : 'Sakrij lozinke'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.text2),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Otkaži'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Promeni lozinku'),
        ),
      ],
    );
  }
}
