import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/repository/campaign_repository.dart';
import '../blocs/campaign_bloc.dart';

class CampaignEditPage extends StatelessWidget {
  final String campaignId;

  const CampaignEditPage({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CampaignBloc(context.read<CampaignRepository>())
        ..add(LoadCampaignDetail(int.tryParse(campaignId) ?? 0)),
      child: _CampaignEditView(campaignId: campaignId),
    );
  }
}

class _CampaignEditView extends StatefulWidget {
  final String campaignId;
  const _CampaignEditView({required this.campaignId});

  @override
  State<_CampaignEditView> createState() => _CampaignEditViewState();
}

class _CampaignEditViewState extends State<_CampaignEditView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  bool _populated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _populateFields(dynamic campaign) {
    if (_populated) return;
    _populated = true;
    _nameController.text = campaign.name ?? '';
    _descriptionController.text = campaign.description ?? '';
    _budgetController.text = campaign.budget?.toString() ?? '';
    _startDateController.text = campaign.startDate ?? '';
    _endDateController.text = campaign.endDate ?? '';
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'startDate': _startDateController.text.trim(),
      'endDate': _endDateController.text.trim(),
    };
    if (_budgetController.text.isNotEmpty) {
      data['budget'] = double.tryParse(_budgetController.text.trim());
    }

    context.read<CampaignBloc>().add(
      UpdateCampaign(int.tryParse(widget.campaignId) ?? 0, data),
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Izmeni kampanju'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocConsumer<CampaignBloc, CampaignState>(
        listener: (context, state) {
          if (state is CampaignFormSuccess) {
            AppSnackbar.show(context, state.message);
            context.pop();
          } else if (state is CampaignError) {
            AppSnackbar.show(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is CampaignLoading && !_populated) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CampaignDetailLoaded) {
            _populateFields(state.campaign);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? AppSpacing.lg : AppSpacing.md),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: l10n.campaignName,
                        controller: _nameController,
                        prefixIcon: Icons.campaign_outlined,
                        validator: (v) => (v == null || v.isEmpty) ? 'Obavezno polje' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.description,
                        controller: _descriptionController,
                        prefixIcon: Icons.description_outlined,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.budget,
                        controller: _budgetController,
                        prefixIcon: Icons.euro,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GestureDetector(
                        onTap: () => _selectDate(_startDateController),
                        child: AbsorbPointer(
                          child: AppTextField(
                            label: l10n.startDate,
                            controller: _startDateController,
                            prefixIcon: Icons.calendar_today,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GestureDetector(
                        onTap: () => _selectDate(_endDateController),
                        child: AbsorbPointer(
                          child: AppTextField(
                            label: l10n.endDate,
                            controller: _endDateController,
                            prefixIcon: Icons.calendar_today,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      BlocBuilder<CampaignBloc, CampaignState>(
                        builder: (context, state) {
                          return PrimaryButton(
                            text: l10n.save,
                            onPressed: _onSave,
                            isLoading: state is CampaignLoading,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
