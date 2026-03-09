import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repository/inquiry_repository.dart';
import '../blocs/inquiry_bloc.dart';

class InquiryCreatePage extends StatelessWidget {
  final List<String> unitIds;

  const InquiryCreatePage({super.key, this.unitIds = const []});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InquiryBloc(context.read<InquiryRepository>()),
      child: _InquiryCreateForm(unitIds: unitIds),
    );
  }
}

class _InquiryCreateForm extends StatefulWidget {
  final List<String> unitIds;

  const _InquiryCreateForm({required this.unitIds});

  @override
  State<_InquiryCreateForm> createState() => _InquiryCreateFormState();
}

class _InquiryCreateFormState extends State<_InquiryCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _campaignBriefController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _campaignBriefController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.newInquiry),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocConsumer<InquiryBloc, InquiryState>(
        listener: (context, state) {
          if (state is InquirySubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.inquiryCreated)),
            );
            context.pop();
          }
          if (state is InquiryError) {
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
                  // Contact Information Section
                  _buildSectionLabel(l10n.contactInformation),
                  const SizedBox(height: AppSpacing.sm),
                  _buildTextField(
                    controller: _contactNameController,
                    label: l10n.contactName,
                    prefixIcon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.isEmpty ? l10n.validatorRequired : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    controller: _contactEmailController,
                    label: l10n.contactEmail,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.validatorEmailRequired;
                      if (!v.contains('@') || !v.contains('.')) {
                        return l10n.validatorEmailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    controller: _contactPhoneController,
                    label: l10n.contactPhone,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Campaign Details Section
                  _buildSectionLabel(l10n.campaignDetails),
                  const SizedBox(height: AppSpacing.sm),
                  _buildTextField(
                    controller: _campaignBriefController,
                    label: l10n.campaignBrief,
                    maxLines: 4,
                    validator: (v) =>
                        v == null || v.isEmpty ? l10n.validatorRequired : null,
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
                    label: l10n.budget,
                    keyboardType: TextInputType.number,
                    prefixText: '€ ',
                  ),

                  // Selected Units
                  if (widget.unitIds.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectionLabel(l10n.selectedUnits),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${widget.unitIds.length} ${l10n.items.toLowerCase()}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Submit Button
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
                          : Text(l10n.submitInquiry,
                              style: AppTypography.button),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTypography.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefixText,
    IconData? prefixIcon,
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
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: AppColors.mutedForeground)
            : null,
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
          firstDate: DateTime.now(),
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
          suffixIcon: Icon(Icons.calendar_today,
              size: 18, color: AppColors.mutedForeground),
        ),
        child: Text(
          date != null
              ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
              : '—',
          style: AppTypography.bodyMedium.copyWith(
            color: date != null
                ? AppColors.foreground
                : AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = <String, dynamic>{
      'contactName': _contactNameController.text.trim(),
      'contactEmail': _contactEmailController.text.trim(),
    };

    if (_contactPhoneController.text.isNotEmpty) {
      data['contactPhone'] = _contactPhoneController.text.trim();
    }
    if (_campaignBriefController.text.isNotEmpty) {
      data['campaignBrief'] = _campaignBriefController.text.trim();
    }
    if (_startDate != null) {
      data['startDate'] = _formatDate(_startDate!);
    }
    if (_endDate != null) {
      data['endDate'] = _formatDate(_endDate!);
    }
    if (_budgetController.text.isNotEmpty) {
      data['budget'] = double.tryParse(_budgetController.text);
    }
    if (widget.unitIds.isNotEmpty) {
      data['unitIds'] = widget.unitIds.map((id) => int.tryParse(id) ?? 0).toList();
    }

    context.read<InquiryBloc>().add(CreateInquiry(data));
  }
}
