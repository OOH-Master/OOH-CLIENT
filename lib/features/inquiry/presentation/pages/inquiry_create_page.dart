import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../data/repository/inquiry_repository.dart';
import '../../domain/entities/unit_summary.dart';
import '../blocs/inquiry_bloc.dart';
import '../utils/inquiry_errors.dart';
import '../widgets/inquiry_layout.dart';
import '../widgets/inquiry_unit_row.dart';

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
  static const _required = 'Obavezno polje';

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

  // Izabrane površine za prikaz (fotografija, lokacija, cena); null = učitava se.
  Map<String, UnitSummary?>? _selectedUnits;

  @override
  void initState() {
    super.initState();
    _selectedFlow = widget.unitIds.isNotEmpty
        ? InquiryFlow.selectInventory
        : InquiryFlow.campaignBrief;
    _prefillFromProfile();
    _loadDictionaries();
    _loadSelectedUnits();
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
          _availableCities = (citiesResponse.data ?? []).map((json) {
            final m = json as Map<String, dynamic>;
            return _DictItem(m['id'] as int, m['name'] as String);
          }).toList();
          _availableMediaTypes = (unitTypesResponse.data ?? []).map((json) {
            final m = json as Map<String, dynamic>;
            return _DictItem(m['id'] as int, m['name'] as String);
          }).toList();
          _loadingDictionaries = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDictionaries = false);
    }
  }

  /// Samo za prikaz: podaci izabranih površina iz javnog inventara.
  Future<void> _loadSelectedUnits() async {
    if (widget.unitIds.isEmpty) return;
    final repository = context.read<InquiryRepository>();
    final result = <String, UnitSummary?>{};
    await Future.wait(widget.unitIds.map((id) async {
      final parsed = int.tryParse(id);
      try {
        result[id] = parsed == null ? null : await repository.getUnit(parsed);
      } catch (_) {
        result[id] = null;
      }
    }));
    if (mounted) setState(() => _selectedUnits = result);
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
    return InquiryScaffold(
      title: 'Novi upit',
      body: BlocConsumer<InquiryBloc, InquiryState>(
        listener: (context, state) {
          if (state is InquirySubmitSuccess) {
            showInquirySnack(context, 'Upit je uspešno poslat', success: true);
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/app/inquiries');
            }
          }
          if (state is InquiryError) {
            setState(() => _isSubmitting = false);
            showInquirySnack(context, InquiryErrors.describe(state.message),
                error: true);
          }
        },
        builder: (context, state) {
          final wide = InquiryLayout.isWide(context);
          return LayoutBuilder(builder: (context, constraints) {
            final gutter =
                InquiryLayout.gutter(constraints.maxWidth, wide: wide);
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 40),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const InquiryHeader(
                          title: 'Novi upit',
                          showBack: true,
                        ),
                        _buildFlowSelector(),
                        const SizedBox(height: 16),
                        _buildContactSection(),
                        const SizedBox(height: 16),
                        if (_selectedFlow == InquiryFlow.selectInventory)
                          _buildFlowA()
                        else
                          _buildFlowB(),
                        const SizedBox(height: 24),
                        _buildSubmit(wide),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildSubmit(bool wide) {
    final button = FilledButton.icon(
      onPressed: _isSubmitting ? null : _onSubmit,
      icon: _isSubmitting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.subtle),
            )
          : const Icon(Icons.send_rounded, size: 18),
      label: const Text('Pošalji upit'),
      style: FilledButton.styleFrom(minimumSize: const Size(220, 50)),
    );
    if (!wide) return button;
    return Align(alignment: Alignment.centerRight, child: button);
  }

  Widget _buildFlowSelector() {
    return SectionCard(
      title: 'Vrsta upita',
      child: Align(
        alignment: Alignment.centerLeft,
        child: SegmentedButton<InquiryFlow>(
          segments: const [
            ButtonSegment(
              value: InquiryFlow.selectInventory,
              label: Text('Izbor površina'),
            ),
            ButtonSegment(
              value: InquiryFlow.campaignBrief,
              label: Text('Brif kampanje'),
            ),
          ],
          showSelectedIcon: false,
          selected: {_selectedFlow},
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              setState(() => _selectedFlow = selection.first);
            }
          },
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: AppColors.primarySoft,
            selectedForegroundColor: AppColors.primaryStrong,
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    final name = _buildTextField(
      controller: _contactNameController,
      label: 'Kontakt osoba',
      validator: (v) => v == null || v.isEmpty ? _required : null,
    );
    final email = _buildTextField(
      controller: _contactEmailController,
      label: 'Email',
      keyboardType: TextInputType.emailAddress,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Unesite email';
        if (!v.contains('@') || !v.contains('.')) {
          return 'Unesite ispravan email';
        }
        return null;
      },
    );
    final phone = _buildTextField(
      controller: _contactPhoneController,
      label: 'Telefon',
      keyboardType: TextInputType.phone,
    );
    return SectionCard(
      title: 'Kontakt',
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: name),
                  const SizedBox(width: 12),
                  Expanded(child: email),
                ],
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: phone),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ]),
            ],
          );
        }
        return Column(
          children: [
            name,
            const SizedBox(height: 12),
            email,
            const SizedBox(height: 12),
            phone,
          ],
        );
      }),
    );
  }

  Widget _buildDates() {
    return Row(
      children: [
        Expanded(child: _buildDateField(true)),
        const SizedBox(width: 12),
        Expanded(child: _buildDateField(false)),
      ],
    );
  }

  Widget _buildBudget() => _buildTextField(
        controller: _budgetController,
        label: 'Budžet',
        keyboardType: TextInputType.number,
        suffixText: '€',
      );

  Widget _buildFlowA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Detalji kampanje',
          child: Column(
            children: [
              _buildTextField(
                controller: _campaignBriefController,
                label: 'Opis kampanje',
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? _required : null,
              ),
              const SizedBox(height: 12),
              _buildDates(),
              const SizedBox(height: 12),
              _buildBudget(),
            ],
          ),
        ),

        // Selected Units
        if (widget.unitIds.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSelectedUnits(),
        ],
      ],
    );
  }

  Widget _buildSelectedUnits() {
    final units = _selectedUnits;
    return SectionCard(
      title: 'Izabrane površine',
      subtitle: SrFormat.count(
          widget.unitIds.length, 'površina', 'površine', 'površina'),
      child: units == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < widget.unitIds.length; i++) ...[
                  if (i > 0) const Divider(color: AppColors.borderSoft),
                  _selectedUnitRow(widget.unitIds[i], units[widget.unitIds[i]]),
                ],
              ],
            ),
    );
  }

  Widget _selectedUnitRow(String id, UnitSummary? unit) {
    final summary = unit ?? UnitSummary.basic(id: int.tryParse(id));
    final price = summary.pricePerCycle;
    return InquiryUnitRow(
      unit: summary,
      trailing: (context, narrow) => PriceColumn(
        amount: price == null
            ? 'Cena na upit'
            : SrFormat.priceWithCycle(
                price, summary.currency, summary.cycleType),
        muted: price == null,
        fontSize: 15,
        footnote: summary.mediaOwnerName,
      ),
    );
  }

  Widget _buildChips(
      List<_DictItem> items, Set<int> selected, String Function(String) label) {
    if (_loadingDictionaries) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selected.contains(item.id);
        return FilterChip(
          label: Text(label(item.name)),
          selected: isSelected,
          onSelected: (value) {
            setState(() {
              if (value) {
                selected.add(item.id);
              } else {
                selected.remove(item.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildFlowB() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Opis kampanje',
          child: _buildTextField(
            controller: _campaignDescriptionController,
            label: 'Detaljni opis kampanje',
            maxLines: 4,
            validator: (v) => v == null || v.isEmpty ? _required : null,
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Ciljani gradovi',
          child: _buildChips(_availableCities, _selectedCityIds, SrLabels.city),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Tipovi medija',
          child: _buildChips(
              _availableMediaTypes, _selectedMediaTypeIds, SrLabels.unitType),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Budžet i period',
          child: Column(
            children: [
              _buildBudget(),
              const SizedBox(height: 12),
              _buildDates(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Publika i dodatni zahtevi',
          child: Column(
            children: [
              _buildTextField(
                controller: _targetAudienceController,
                label: 'Ciljna publika',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _additionalRequirementsController,
                label: 'Dodatni zahtevi',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        suffixText: suffixText,
      ),
    );
  }

  Widget _buildDateField(bool isStart) {
    final date = isStart ? _startDate : _endDate;
    final label = isStart ? 'Početak kampanje' : 'Kraj kampanje';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
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
          suffixIcon: const Icon(Icons.calendar_today_outlined,
              size: 18, color: AppColors.mutedForeground),
        ),
        child: Text(
          date != null ? SrFormat.date(date) : '—',
          style: AppTypography.bodyMedium.copyWith(
            color:
                date != null ? AppColors.foreground : AppColors.mutedForeground,
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
        data['unitIds'] =
            widget.unitIds.map((id) => int.tryParse(id) ?? 0).toList();
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
        data['additionalRequirements'] =
            _additionalRequirementsController.text.trim();
      }
    }

    context.read<InquiryBloc>().add(CreateInquiry(data));
  }
}
