import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../data/dto/campaign_dto.dart';
import '../../data/repository/campaign_repository.dart';
import '../blocs/campaign_bloc.dart';
import '../widgets/campaign_form_widgets.dart';

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
  // Datumi u ISO obliku ("2026-11-16"), kako ih API prima.
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

  void _populateFields(CampaignDto campaign) {
    if (_populated) return;
    _populated = true;
    _nameController.text = campaign.name ?? '';
    _descriptionController.text = campaign.description ?? '';
    final budget = campaign.budget;
    _budgetController.text = budget == null
        ? ''
        : (budget == budget.roundToDouble()
            ? budget.toInt().toString()
            : budget.toString());
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
      data['budget'] = campaignBudget(_budgetController.text);
    }

    context.read<CampaignBloc>().add(
          UpdateCampaign(int.tryParse(widget.campaignId) ?? 0, data),
        );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final current = SrFormat.parseDate(controller.text);
    final initial = (current != null &&
            !current.isBefore(DateTime(2020)) &&
            !current.isAfter(DateTime(2030)))
        ? current
        : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => controller.text = campaignIsoDate(date));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<CampaignBloc, CampaignState>(
      listener: (context, state) {
        if (state is CampaignFormSuccess) {
          AppSnackbar.show(context, state.message);
          context.pop();
        } else if (state is CampaignError) {
          AppSnackbar.show(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        if (state is CampaignDetailLoaded) {
          _populateFields(state.campaign);
        }
        final loadingDetail =
            (state is CampaignLoading || state is CampaignInitial) &&
                !_populated;
        final start = SrFormat.parseDate(_startDateController.text);
        final end = SrFormat.parseDate(_endDateController.text);

        return CampaignFormScaffold(
          title: 'Izmena kampanje',
          subtitle:
              _nameController.text.isEmpty ? null : _nameController.text,
          loading: state is CampaignLoading,
          saveLabel: l10n.save,
          onSave: _onSave,
          builder: (context, width) {
            if (loadingDetail) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return Form(
              key: _formKey,
              child: CampaignFormColumns(
                width: width,
                left: [
                  CampaignFormSection(
                    title: 'Osnovno',
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: '${l10n.campaignName} *',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Obavezno polje' : null,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        minLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.description,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ],
                right: [
                  CampaignFormSection(
                    title: 'Period i budžet',
                    children: [
                      CampaignDateField(
                        label: l10n.startDate,
                        value: start,
                        onTap: () => _selectDate(_startDateController),
                      ),
                      CampaignDateField(
                        label: l10n.endDate,
                        value: end,
                        onTap: () => _selectDate(_endDateController),
                      ),
                      if (start != null && end != null)
                        CampaignPeriodHint(start: start, end: end),
                      TextFormField(
                        controller: _budgetController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.budget,
                          suffixText: '€',
                          prefixIcon: const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
