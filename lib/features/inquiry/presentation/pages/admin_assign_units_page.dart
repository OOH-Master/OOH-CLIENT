import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/domain/entities/role.dart';
import '../../data/repository/inquiry_repository.dart';
import '../../domain/entities/currency_totals.dart';
import '../../domain/entities/inquiry.dart';
import '../../domain/entities/unit_summary.dart';
import '../utils/inquiry_errors.dart';
import '../widgets/inquiry_layout.dart';
import '../widgets/inquiry_unit_row.dart';

/// Admin-only page for attaching inventory units to a BRIEF inquiry.
/// Opens the full public inventory list with checkbox selection; on submit
/// posts to `POST /api/v1/admin/inquiries/{id}/assign-units`.
class AdminAssignUnitsPage extends StatelessWidget {
  final int inquiryId;

  const AdminAssignUnitsPage({super.key, required this.inquiryId});

  @override
  Widget build(BuildContext context) {
    return _AssignUnitsView(inquiryId: inquiryId);
  }
}

class _AssignUnitsView extends StatefulWidget {
  final int inquiryId;

  const _AssignUnitsView({required this.inquiryId});

  @override
  State<_AssignUnitsView> createState() => _AssignUnitsViewState();
}

class _AssignUnitsViewState extends State<_AssignUnitsView> {
  late final InquiryRepository _inquiry;
  final _searchController = TextEditingController();
  List<UnitSummary> _units = [];
  Inquiry? _brief;
  final Set<int> _selected = {};
  bool _loading = true;
  bool _submitting = false;
  Object? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _inquiry = context.read<InquiryRepository>();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    // Brif je samo kontekst: ako se ne učita, lista površina i dalje radi.
    final briefFuture = _inquiry
        .getInquiryById(widget.inquiryId, Role.admin)
        .then<Inquiry?>((i) => i)
        .catchError((Object _) => null);
    try {
      final units = await _inquiry.getAssignableUnits();
      final brief = await briefFuture;
      if (!mounted) return;
      setState(() {
        _units = units;
        _brief = brief;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) return;
    setState(() => _submitting = true);
    final ids = _selected.toList();
    try {
      await _inquiry.assignUnits(widget.inquiryId, ids);
      if (!mounted) return;
      showInquirySnack(
        context,
        'Upitu #${widget.inquiryId} dodeljeno: ${SrFormat.count(ids.length, 'površina', 'površine', 'površina')}',
        success: true,
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/app/admin/inquiries');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showInquirySnack(context, InquiryErrors.describe(e), error: true);
    }
  }

  /// Površine koje su već u upitu (ne dodeljuju se ponovo).
  Set<int> get _assigned => {
        for (final item in _brief?.items ?? const <InquiryItem>[])
          if (item.inventoryItemId != null) item.inventoryItemId!,
      };

  // Pretraga bez obzira na dijakritike: "nis" nalazi "Niš".
  static String _fold(String s) => s
      .toLowerCase()
      .replaceAll('č', 'c')
      .replaceAll('ć', 'c')
      .replaceAll('š', 's')
      .replaceAll('ž', 'z')
      .replaceAll('đ', 'dj');

  List<UnitSummary> get _filtered {
    final q = _fold(_search.trim());
    if (q.isEmpty) return _units;
    return _units.where((u) => _fold(u.searchText).contains(q)).toList();
  }

  /// Broj ciklusa za period upita, kao na serveru (zaokruženo naviše).
  int? _cycles(UnitSummary unit) {
    final start = SrFormat.parseDate(_brief?.startDate);
    final end = SrFormat.parseDate(_brief?.endDate);
    if (start == null || end == null || !end.isAfter(start)) return null;
    final days = end.difference(start).inDays;
    final key =
        (unit.cycleType ?? '').toLowerCase().replaceAll(RegExp(r'[_\-\s]'), '');
    final cycleDays = switch (key) {
      '1day' || 'oneday' || 'day' => 1,
      '1week' || 'oneweek' || 'week' => 7,
      '2week' || 'twoweek' => 14,
      '4week' || 'fourweek' => 28,
      _ => 30,
    };
    return (days / cycleDays).ceil().clamp(1, 1000);
  }

  /// Zbir izabranih po valuti: cena za period upita kada je period poznat,
  /// inače cena po ciklusu.
  Map<String, double> get _selectedTotals {
    final chosen = _units.where((u) => _selected.contains(u.id));
    return CurrencyTotals.sum(chosen, (u) {
      final price = u.pricePerCycle;
      if (price == null) return null;
      return price * (_cycles(u) ?? 1);
    }, (u) => u.currency);
  }

  @override
  Widget build(BuildContext context) {
    return InquiryScaffold(
      title: 'Dodela površina za upit #${widget.inquiryId}',
      body: _buildBody(),
      bottomBar: _loading || _error != null ? null : _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const InquiryLoadingView();
    if (_error != null) {
      return InquiryErrorView(
        error: _error,
        onRetry: _load,
        title: 'Površine nisu učitane',
      );
    }

    final wide = InquiryLayout.isWide(context);
    final filtered = _filtered;
    final assigned = _assigned;

    return LayoutBuilder(builder: (context, constraints) {
      final gutter = InquiryLayout.gutter(constraints.maxWidth, wide: wide);
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            sliver: SliverList.list(
              children: [
                InquiryHeader(
                  title: 'Dodela površina za upit #${widget.inquiryId}',
                  showBack: true,
                ),
                if (_brief != null) ...[
                  _BriefSummary(inquiry: _brief!),
                  const SizedBox(height: 16),
                ],
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Pretraga po adresi, gradu, vlasniku…',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _search.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Obriši pretragu',
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            },
                          ),
                  ),
                  controller: _searchController,
                  onChanged: (v) => setState(() => _search = v),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
                  child: Text(
                    _search.trim().isEmpty
                        ? SrFormat.count(
                            _units.length, 'površina', 'površine', 'površina')
                        : 'Pronađeno: ${SrFormat.count(filtered.length, 'površina', 'površine', 'površina')}',
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                compact: true,
                icon: Icons.search_off_rounded,
                title: 'Nema površina',
                message: _search.isEmpty
                    ? null
                    : 'Nijedna površina ne odgovara pretrazi.',
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 24),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final unit = filtered[i];
                  final already = assigned.contains(unit.id);
                  return _AssignRow(
                    unit: unit,
                    selected: already || _selected.contains(unit.id),
                    alreadyAssigned: already,
                    onChanged: already
                        ? null
                        : (value) => setState(() {
                              if (value) {
                                _selected.add(unit.id!);
                              } else {
                                _selected.remove(unit.id);
                              }
                            }),
                  );
                },
              ),
            ),
        ],
      );
    });
  }

  Widget _buildBottomBar() {
    final count = _selected.length;
    final totals = CurrencyTotals.labels(_selectedTotals);
    final summary =
        'Izabrano: ${SrFormat.count(count, 'površina', 'površine', 'površina')}';
    // Zbir po cenovniku; bez perioda upita to je cena jednog ciklusa.
    final hasPeriod = _brief?.startDate != null && _brief?.endDate != null;
    final amount = count == 0 || totals.isEmpty ? null : totals.join(', ');
    final budget = _brief?.budget;
    final muted =
        AppTypography.caption.copyWith(color: AppColors.mutedForeground);
    final budgetText = budget == null
        ? null
        : 'Budžet klijenta ${SrFormat.money(budget, 'EUR')}';

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
              color: Color(0x14111433), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(builder: (context, constraints) {
          final gutter = InquiryLayout.gutter(constraints.maxWidth,
              wide: InquiryLayout.isWide(context));
          return Padding(
            padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelLarge),
                      if (amount != null || budgetText != null) ...[
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 16,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (amount != null)
                              Text.rich(TextSpan(
                                text: amount,
                                style: AppTypography.money
                                    .copyWith(fontSize: 14.5),
                                children: [
                                  if (!hasPeriod)
                                    TextSpan(text: ' po ciklusu', style: muted),
                                ],
                              )),
                            if (budgetText != null)
                              Text(budgetText, style: muted),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed:
                      (_selected.isEmpty || _submitting) ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.subtle),
                        )
                      : const Icon(Icons.check_rounded, size: 19),
                  label: const Text('Dodeli'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Brif klijenta iznad liste: opis, budžet, period, gradovi i tipovi medija.
class _BriefSummary extends StatelessWidget {
  final Inquiry inquiry;

  const _BriefSummary({required this.inquiry});

  @override
  Widget build(BuildContext context) {
    final brief = (inquiry.campaignBrief ?? '').trim();
    final noPeriod = inquiry.startDate == null && inquiry.endDate == null;
    return SectionCard(
      title: 'Brif klijenta',
      subtitle: inquiry.clientName,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (brief.isNotEmpty) ...[
            Text(
              brief,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.foreground, height: 1.55),
            ),
            const SizedBox(height: 16),
          ],
          Wrap(
            spacing: 28,
            runSpacing: 14,
            children: [
              MetaItem(
                label: 'Budžet',
                value: inquiry.budget == null
                    ? 'Nije naveden'
                    : SrFormat.money(inquiry.budget, 'EUR'),
                emphasize: inquiry.budget != null,
              ),
              MetaItem(
                label: 'Period kampanje',
                value: noPeriod
                    ? 'Nije naveden'
                    : SrFormat.period(inquiry.startDate, inquiry.endDate),
                note: noPeriod ? null : SrFormat.daysLabel(inquiry.days),
              ),
              if (inquiry.unitCount > 0)
                MetaItem(
                  label: 'Već u upitu',
                  value: SrFormat.count(
                      inquiry.unitCount, 'površina', 'površine', 'površina'),
                ),
              if (inquiry.targetCityNames.isNotEmpty)
                MetaItem(
                  label: 'Ciljani gradovi',
                  value: inquiry.targetCityNames.join(', '),
                ),
              if (inquiry.preferredMediaTypeNames.isNotEmpty)
                MetaItem(
                  label: 'Tipovi medija',
                  value: inquiry.preferredMediaTypeNames.join(', '),
                ),
            ],
          ),
          if ((inquiry.targetAudience ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Ciljna publika: ${inquiry.targetAudience}',
                style:
                    AppTypography.bodySmall.copyWith(color: AppColors.text2)),
          ],
        ],
      ),
    );
  }
}

/// Površina u listi za dodelu: potvrda levo, cena i vlasnik desno; izabrana
/// površina je obojena.
class _AssignRow extends StatelessWidget {
  final UnitSummary unit;
  final bool selected;
  final bool alreadyAssigned;
  final ValueChanged<bool>? onChanged;

  const _AssignRow({
    required this.unit,
    required this.selected,
    required this.alreadyAssigned,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final price = unit.pricePerCycle;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: selected && !alreadyAssigned
            ? AppColors.primarySoft
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected && !alreadyAssigned
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.border,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InquiryUnitRow(
          unit: unit,
          stackBelow: 560,
          onTap: onChanged == null ? null : () => onChanged!(!selected),
          leading: Checkbox(
            value: selected,
            onChanged: onChanged == null ? null : (v) => onChanged!(v ?? false),
          ),
          trailing: (context, narrow) => Row(
            mainAxisSize: narrow ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (alreadyAssigned) ...[
                const StatusPill(
                    label: 'Već u upitu', tone: PillTone.neutral, dense: true),
                const SizedBox(width: 10),
              ],
              PriceColumn(
                amount: price == null
                    ? 'Cena na upit'
                    : SrFormat.priceWithCycle(
                        price, unit.currency, unit.cycleType),
                muted: price == null,
                fontSize: 15,
                footnote: unit.mediaOwnerName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
