import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../data/repository/campaign_repository.dart';
import '../blocs/campaign_bloc.dart';

class CampaignFormPage extends StatelessWidget {
  const CampaignFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CampaignBloc(context.read<CampaignRepository>()),
      child: const _CampaignFormView(),
    );
  }
}

class _CampaignFormView extends StatefulWidget {
  const _CampaignFormView();

  @override
  State<_CampaignFormView> createState() => _CampaignFormViewState();
}

class _CampaignFormViewState extends State<_CampaignFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _brandUsernameController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool get _isAgency {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated && authState.user.role == Role.agency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _brandUsernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.createCampaign),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocConsumer<CampaignBloc, CampaignState>(
        listener: (context, state) {
          if (state is CampaignFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop();
          }
          if (state is CampaignError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.destructive,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: l10n.campaignName,
                    validator: (v) =>
                        v == null || v.isEmpty ? l10n.validatorRequired : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    controller: _descriptionController,
                    label: l10n.campaignDescription,
                    maxLines: 4,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildDateField(true)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: _buildDateField(false)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    controller: _budgetController,
                    label: l10n.campaignBudget,
                    keyboardType: TextInputType.number,
                    prefixText: '€ ',
                  ),
                  if (_isAgency) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildTextField(
                      controller: _brandUsernameController,
                      label: l10n.brandUsername,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(l10n.save, style: AppTypography.button),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildDateField(bool isStart) {
    final date = isStart ? _startDate : _endDate;
    final label = isStart ? l10n.startDate : l10n.endDate;

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() {
            if (isStart) {
              _startDate = picked;
            } else {
              _endDate = picked;
            }
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(color: AppColors.border),
          ),
          suffixIcon:
              Icon(Icons.calendar_today, size: 18, color: AppColors.mutedForeground),
        ),
        child: Text(
          date != null
              ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
              : '—',
          style: AppTypography.bodyMedium.copyWith(
            color: date != null ? AppColors.foreground : AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
    };

    if (_descriptionController.text.isNotEmpty) {
      data['description'] = _descriptionController.text.trim();
    }
    if (_startDate != null) {
      data['startDate'] =
          '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}';
    }
    if (_endDate != null) {
      data['endDate'] =
          '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}';
    }
    if (_budgetController.text.isNotEmpty) {
      data['budget'] = double.tryParse(_budgetController.text);
    }
    if (_isAgency && _brandUsernameController.text.isNotEmpty) {
      data['brandUsername'] = _brandUsernameController.text.trim();
    }

    context.read<CampaignBloc>().add(CreateCampaign(data));
  }
}
