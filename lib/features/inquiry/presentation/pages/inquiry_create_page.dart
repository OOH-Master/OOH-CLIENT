import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
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

enum InquiryFlow { selectInventory, campaignBrief }

/// Lightweight id+name pair for dictionary items
class _DictItem {
  final int id;
  final String name;
  const _DictItem(this.id, this.name);
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
  final _targetAudienceController = TextEditingController();
  final _additionalRequirementsController = TextEditingController();
  final _campaignDescriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;
  late InquiryFlow _selectedFlow;

  // Brief flow fields — selected IDs
  final Set<int> _selectedCityIds = {};
  final Set<int> _selectedMediaTypeIds = {};

  // Loaded from API
  List<_DictItem> _availableCities = [];
  List<_DictItem> _availableMediaTypes = [];
  bool _loadingDictionaries = true;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _selectedFlow = widget.unitIds.isNotEmpty
        ? InquiryFlow.selectInventory
        : InquiryFlow.campaignBrief;
    _prefillFromProfile();
    _loadDictionaries();
  }

  void _prefillFromProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      final name = user.contactPerson ??
          [user.firstName, user.lastName]
              .where((s) => s != null && s.isNotEmpty)
              .join(' ');
      if (name.isNotEmpty) _contactNameController.text = name;
      if (user.email.isNotEmpty) _contactEmailController.text = user.email;
      if (user.phone != null && user.phone!.isNotEmpty) {
        _contactPhoneController.text = user.phone!;
      }
    }
  }

  Future<void> _loadDictionaries() async {
    try {
      final apiClient = context.read<ApiClient>();

      final citiesResponse =
          await apiClient.get<List<dynamic>>(ApiConfig.publicCities);
      final unitTypesResponse =
          await apiClient.get<List<dynamic>>(ApiConfig.publicUnitTypes);

      if (mounted) {
        setState(() {
          _availableCities = (citiesResponse.data ?? [])
              .map((json) {
                final m = json as Map<String, dynamic>;
                return _DictItem(m['id'] as int, m['name'] as String);
              })
              .toList();
          _availableMediaTypes = (unitTypesResponse.data ?? [])
              .map((json) {
                final m = json as Map<String, dynamic>;
                return _DictItem(m['id'] as int, m['name'] as String);
              })
              .toList();
          _loadingDictionaries = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDictionaries = false);
    }
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _campaignBriefController.dispose();
    _budgetController.dispose();
    _targetAudienceController.dispose();
    _additionalRequirementsController.dispose();
    _campaignDescriptionController.dispose();
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
                  // Flow Selector
                  _buildFlowSelector(),
                  const SizedBox(height: AppSpacing.lg),

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

                  if (_selectedFlow == InquiryFlow.selectInventory)
                    _buildFlowA()
                  else
                    _buildFlowB(),

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

  Widget _buildFlowSelector() {
    return SegmentedButton<InquiryFlow>(
      segments: [
        ButtonSegment(
          value: InquiryFlow.selectInventory,
          label: const Text('Odaberi inventar'),
          icon: const Icon(Icons.inventory_2_outlined, size: 18),
        ),
        ButtonSegment(
          value: InquiryFlow.campaignBrief,
          label: const Text('Opis kampanje'),
          icon: const Icon(Icons.description_outlined, size: 18),
        ),
      ],
      selected: {_selectedFlow},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          setState(() => _selectedFlow = selection.first);
        }
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
        selectedForegroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildFlowA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          prefixText: 'EUR ',
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
      ],
    );
  }

  Widget _buildFlowB() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campaign Description
        _buildSectionLabel('Opis kampanje'),
        const SizedBox(height: AppSpacing.sm),
        _buildTextField(
          controller: _campaignDescriptionController,
          label: 'Detaljni opis kampanje',
          maxLines: 4,
          validator: (v) =>
              v == null || v.isEmpty ? l10n.validatorRequired : null,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Target Cities
        _buildSectionLabel('Ciljani gradovi'),
        const SizedBox(height: AppSpacing.sm),
        if (_loadingDictionaries)
          const Center(child: CircularProgressIndicator())
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableCities.map((city) {
              final isSelected = _selectedCityIds.contains(city.id);
              return FilterChip(
                label: Text(city.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCityIds.add(city.id);
                    } else {
                      _selectedCityIds.remove(city.id);
                    }
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                checkmarkColor: AppColors.primary,
                labelStyle: AppTypography.bodySmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.foreground,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: AppSpacing.lg),

        // Preferred Media Types
        _buildSectionLabel('Preferirani tipovi medija'),
        const SizedBox(height: AppSpacing.sm),
        if (_loadingDictionaries)
          const Center(child: CircularProgressIndicator())
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableMediaTypes.map((type) {
              final isSelected = _selectedMediaTypeIds.contains(type.id);
              return FilterChip(
                label: Text(type.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedMediaTypeIds.add(type.id);
                    } else {
                      _selectedMediaTypeIds.remove(type.id);
                    }
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                checkmarkColor: AppColors.primary,
                labelStyle: AppTypography.bodySmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.foreground,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: AppSpacing.lg),

        // Budget Range
        _buildTextField(
          controller: _budgetController,
          label: l10n.budget,
          keyboardType: TextInputType.number,
          prefixText: 'EUR ',
        ),
        const SizedBox(height: AppSpacing.md),

        // Campaign Period
        Row(
          children: [
            Expanded(child: _buildDateField(true)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildDateField(false)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Target Audience
        _buildTextField(
          controller: _targetAudienceController,
          label: 'Ciljna publika',
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.md),

        // Additional Requirements
        _buildTextField(
          controller: _additionalRequirementsController,
          label: 'Dodatni zahtevi',
          maxLines: 3,
        ),
      ],
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
              ? _formatDate(date)
              : '\u2014',
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
    if (_startDate != null) {
      data['startDate'] = _formatDate(_startDate!);
    }
    if (_endDate != null) {
      data['endDate'] = _formatDate(_endDate!);
    }
    if (_budgetController.text.isNotEmpty) {
      data['budget'] = double.tryParse(_budgetController.text);
    }

    if (_selectedFlow == InquiryFlow.selectInventory) {
      if (_campaignBriefController.text.isNotEmpty) {
        data['campaignBrief'] = _campaignBriefController.text.trim();
      }
      if (widget.unitIds.isNotEmpty) {
        data['unitIds'] = widget.unitIds.map((id) => int.tryParse(id) ?? 0).toList();
      }
    } else {
      // Brief flow
      data['campaignBrief'] = _campaignDescriptionController.text.trim();
      data['inquiryType'] = 'BRIEF';
      if (_selectedCityIds.isNotEmpty) {
        data['targetCityIds'] = _selectedCityIds.toList();
      }
      if (_selectedMediaTypeIds.isNotEmpty) {
        data['preferredMediaTypeIds'] = _selectedMediaTypeIds.toList();
      }
      if (_targetAudienceController.text.isNotEmpty) {
        data['targetAudience'] = _targetAudienceController.text.trim();
      }
      if (_additionalRequirementsController.text.isNotEmpty) {
        data['additionalRequirements'] = _additionalRequirementsController.text.trim();
      }
    }

    context.read<InquiryBloc>().add(CreateInquiry(data));
  }
}
