import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';

/// Izmena kontakt podataka korisnika (stručnjak za lokacije).
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
    _firstNameController =
        TextEditingController(text: widget.user['firstName'] ?? '');
    _lastNameController =
        TextEditingController(text: widget.user['lastName'] ?? '');
    _emailController = TextEditingController(text: widget.user['email'] ?? '');
    _companyNameController =
        TextEditingController(text: widget.user['companyName'] ?? '');
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

  Widget _field(String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboard}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = (widget.user['username'] as String?) ?? '';
    final role = (widget.user['role'] as String?) ?? '';
    final company = (widget.user['companyName'] as String?)?.trim() ?? '';
    final name = company.isNotEmpty ? company : username;

    return AlertDialog(
      title: const Text('Izmena korisnika'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: AppDecorations.sunken(),
                child: Row(
                  children: [
                    AppAvatar(name: name.isEmpty ? '?' : name, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.isEmpty ? '—' : name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelLarge),
                          if (username.isNotEmpty)
                            Text('@$username',
                                style: AppTypography.caption.copyWith(
                                    color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                    if (role.isNotEmpty)
                      StatusPill(
                        label: SrLabels.role(role),
                        tone: PillTone.primary,
                        dot: false,
                        dense: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _field(
                        'Ime', _firstNameController, Icons.badge_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                        'Prezime', _lastNameController, Icons.badge_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _field('Email', _emailController, Icons.email_outlined,
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _field('Naziv kompanije', _companyNameController,
                  Icons.business_outlined),
              const SizedBox(height: 14),
              _field('Telefon', _phoneController, Icons.phone_outlined,
                  keyboard: TextInputType.phone),
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
          child: const Text('Sačuvaj'),
        ),
      ],
    );
  }
}
