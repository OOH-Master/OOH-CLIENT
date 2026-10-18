import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../data/repository/campaign_repository.dart';
import '../blocs/campaign_bloc.dart';
import '../widgets/campaign_form_widgets.dart';

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

  Future<void> _pickDate(bool isStart) async {
    final current = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? (isStart ? null : _startDate) ?? DateTime.now(),
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
    if (_startDate != null) data['startDate'] = campaignIsoDate(_startDate!);
    if (_endDate != null) data['endDate'] = campaignIsoDate(_endDate!);
    if (_budgetController.text.isNotEmpty) {
      data['budget'] = campaignBudget(_budgetController.text);
    }
    if (_isAgency && _brandUsernameController.text.isNotEmpty) {
      data['brandUsername'] = _brandUsernameController.text.trim();
    }

    context.read<CampaignBloc>().add(CreateCampaign(data));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CampaignBloc, CampaignState>(
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
      child: CampaignFormScaffold(
        title: 'Nova kampanja',
        loading: _isSubmitting,
        saveLabel: 'Sačuvaj kampanju',
        onSave: _onSubmit,
        builder: (context, width) => Form(
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
                      hintText: 'npr. Jesenja kampanja Beograd',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? l10n.validatorRequired : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    minLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.campaignDescription,
                      hintText: 'Cilj kampanje, ciljna grupa, napomene',
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
                    value: _startDate,
                    onTap: () => _pickDate(true),
                  ),
                  CampaignDateField(
                    label: l10n.endDate,
                    value: _endDate,
                    onTap: () => _pickDate(false),
                  ),
                  if (_startDate != null && _endDate != null)
                    CampaignPeriodHint(start: _startDate, end: _endDate),
                  TextFormField(
                    controller: _budgetController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.campaignBudget,
                      hintText: 'npr. 5000',
                      suffixText: '€',
                      prefixIcon: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 20),
                    ),
                  ),
                ],
              ),
              if (_isAgency)
                CampaignFormSection(
                  title: 'Brend',
                  children: [
                    TextFormField(
                      controller: _brandUsernameController,
                      decoration: InputDecoration(
                        labelText: l10n.brandUsername,
                        prefixIcon:
                            const Icon(Icons.storefront_outlined, size: 20),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
