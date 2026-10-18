import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/domain/entities/role.dart';
import '../../data/repository/inquiry_repository.dart';
import '../../domain/entities/inquiry.dart';
import '../blocs/inquiry_bloc.dart';
import '../utils/inquiry_errors.dart';
import '../widgets/inquiry_card.dart';
import '../widgets/inquiry_layout.dart';
import '../widgets/inquiry_status_badge.dart';

class AdminInquiryManagementPage extends StatelessWidget {
  const AdminInquiryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InquiryBloc(context.read<InquiryRepository>())
        ..add(LoadInquiries(Role.admin)),
      child: const _AdminInquiryManagementView(),
    );
  }
}

class _AdminInquiryManagementView extends StatefulWidget {
  const _AdminInquiryManagementView();

  @override
  State<_AdminInquiryManagementView> createState() =>
      _AdminInquiryManagementViewState();
}

class _AdminInquiryManagementViewState
    extends State<_AdminInquiryManagementView> {
  static const _title = 'Upravljanje upitima';

  InquiryStatus? _statusFilter;
  String? _requesterTypeFilter;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<Inquiry>? _last;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Inquiry> _filterInquiries(List<Inquiry> inquiries) {
    var filtered = inquiries;

    if (_statusFilter != null) {
      filtered = filtered.where((i) => i.status == _statusFilter).toList();
    }

    if (_requesterTypeFilter != null) {
      filtered = filtered
          .where((i) => i.requesterType == _requesterTypeFilter)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().replaceAll('#', '').trim();
      filtered = filtered.where((i) {
        return (i.requesterName?.toLowerCase().contains(query) ?? false) ||
            (i.contactName?.toLowerCase().contains(query) ?? false) ||
            (i.contactEmail?.toLowerCase().contains(query) ?? false) ||
            i.id.toString().contains(query);
      }).toList();
    }

    return filtered;
  }

  void _handleAction(BuildContext context, Inquiry inquiry, String action) {
    final bloc = context.read<InquiryBloc>();
    switch (action) {
      case 'start_processing':
        bloc.add(
            TransitionInquiryStatus(inquiry.id, 'IN_PROGRESS', Role.admin));
        break;
      case 'request_quotes':
        bloc.add(RequestQuotes(inquiry.id));
        break;
      case 'send_offer':
        bloc.add(SendOffer(inquiry.id));
        break;
    }
  }

  void _reload() => context.read<InquiryBloc>().add(LoadInquiries(Role.admin));

  /// Posle detalja ili dodele površina lista se osvežava.
  void _open(String location) {
    context.push(location).then((_) {
      if (mounted) _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return InquiryScaffold(
      title: _title,
      body: BlocConsumer<InquiryBloc, InquiryState>(
        listener: (context, state) {
          if (state is InquiryActionSuccess) {
            showInquirySnack(context, state.message, success: true);
            context.read<InquiryBloc>().add(LoadInquiries(Role.admin));
          }
          if (state is InquiryError && _last != null) {
            showInquirySnack(context, InquiryErrors.describe(state.message),
                error: true);
          }
        },
        builder: (context, state) {
          if (state is InquiriesLoaded) _last = state.inquiries;
          final inquiries = _last;
          if (inquiries == null) {
            if (state is InquiryError) {
              return InquiryErrorView(error: state.message, onRetry: _reload);
            }
            return const InquiryLoadingView();
          }
          return Column(
            children: [
              InquiryRefreshBar(visible: state is InquiryLoading),
              Expanded(child: _buildContent(inquiries)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(List<Inquiry> all) {
    final wide = InquiryLayout.isWide(context);
    final filtered = _filterInquiries(all);
    return LayoutBuilder(builder: (context, constraints) {
      final gutter = InquiryLayout.gutter(constraints.maxWidth, wide: wide);
      final contentWidth = constraints.maxWidth - 2 * gutter;
      final table = contentWidth >= 1040;

      return RefreshIndicator(
        onRefresh: () async => _reload(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 40),
          children: [
            const InquiryHeader(title: _title),
            _buildToolbar(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                filtered.length == all.length
                    ? SrFormat.count(all.length, 'upit', 'upita', 'upita')
                    : 'Prikazano ${filtered.length} od ${SrFormat.count(all.length, 'upit', 'upita', 'upita')}',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.mutedForeground),
              ),
            ),
            if (filtered.isEmpty)
              const SectionCard(
                child: EmptyState(
                  compact: true,
                  icon: Icons.inbox_outlined,
                  title: 'Nema upita',
                  message: 'Nijedan upit ne odgovara pretrazi i filterima.',
                ),
              )
            else if (table)
              _InquiryTable(
                inquiries: filtered,
                onOpen: (i) => _open('/app/inquiries/${i.id}'),
                actionsFor: (i) => _buildActionButtons(context, i),
              )
            else
              InquiryCardGrid(
                itemCount: filtered.length,
                itemBuilder: (context, index, fill) {
                  final inquiry = filtered[index];
                  final actions = _buildActionButtons(context, inquiry);
                  return InquiryCard(
                    inquiry: inquiry,
                    fill: fill,
                    showClient: true,
                    onTap: () => _open('/app/inquiries/${inquiry.id}'),
                    footer: actions,
                  );
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildToolbar() {
    final search = TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: InputDecoration(
        hintText: 'Pretraži po klijentu, emailu ili broju upita',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        isDense: true,
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: 'Obriši pretragu',
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
      ),
    );

    final status = DropdownButtonFormField<InquiryStatus?>(
      initialValue: _statusFilter,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Status', isDense: true),
      items: [
        const DropdownMenuItem(value: null, child: Text('Svi statusi')),
        ...InquiryStatus.values.map((s) => DropdownMenuItem(
              value: s,
              child: Text(
                InquiryStatusBadge.labelFor(s),
                overflow: TextOverflow.ellipsis,
              ),
            )),
      ],
      onChanged: (v) => setState(() => _statusFilter = v),
    );

    final requester = DropdownButtonFormField<String?>(
      initialValue: _requesterTypeFilter,
      isExpanded: true,
      decoration:
          const InputDecoration(labelText: 'Tip klijenta', isDense: true),
      items: [
        const DropdownMenuItem(value: null, child: Text('Svi klijenti')),
        DropdownMenuItem(
            value: 'BRAND', child: Text(SrLabels.requesterType('BRAND'))),
        DropdownMenuItem(
            value: 'AGENCY', child: Text(SrLabels.requesterType('AGENCY'))),
      ],
      onChanged: (v) => setState(() => _requesterTypeFilter = v),
    );

    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 12),
              SizedBox(width: 230, child: status),
              const SizedBox(width: 12),
              SizedBox(width: 190, child: requester),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            search,
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: status),
                const SizedBox(width: 12),
                Expanded(child: requester),
              ],
            ),
          ],
        );
      }),
    );
  }

  /// Akcije stručnjaka po statusu, kao i do sada: brif se pokreće i dobija
  /// površine, zatim se traže cene i šalje ponuda.
  Widget? _buildActionButtons(BuildContext context, Inquiry inquiry) {
    switch (inquiry.status) {
      case InquiryStatus.submitted:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionButton(
              label: 'Pokreni obradu',
              primary: true,
              onPressed: () =>
                  _handleAction(context, inquiry, 'start_processing'),
            ),
            _ActionButton(
              label: 'Dodeli jedinice',
              onPressed: () =>
                  _open('/app/admin/inquiries/${inquiry.id}/assign-units'),
            ),
          ],
        );
      case InquiryStatus.inProgress:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionButton(
              label: 'Zatraži ponude',
              primary: true,
              onPressed: () =>
                  _handleAction(context, inquiry, 'request_quotes'),
            ),
            _ActionButton(
              label: 'Dodeli jedinice',
              onPressed: () =>
                  _open('/app/admin/inquiries/${inquiry.id}/assign-units'),
            ),
          ],
        );
      case InquiryStatus.pricingReady:
        return _ActionButton(
          label: 'Pošalji ponudu',
          primary: true,
          onPressed: () => _handleAction(context, inquiry, 'send_offer'),
        );
      default:
        return null;
    }
  }
}

/// Kompaktno dugme akcije u tabeli: prva akcija indigo, druga neutralna.
class _ActionButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextButton.styleFrom(
      foregroundColor: primary ? AppColors.primaryStrong : AppColors.text2,
      backgroundColor: primary ? AppColors.primarySoft : AppColors.surface,
      minimumSize: const Size(0, 34),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle:
          AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: primary
            ? BorderSide.none
            : const BorderSide(color: AppColors.border),
      ),
    );
    return TextButton(onPressed: onPressed, style: style, child: Text(label));
  }
}

/// Tabela upita na širokom ekranu: zaglavlje u uvučenoj boji (sitno, sivo,
/// rečenični oblik), redovi sa tankim linijama i isticanjem pod mišem.
class _InquiryTable extends StatelessWidget {
  final List<Inquiry> inquiries;
  final ValueChanged<Inquiry> onOpen;
  final Widget? Function(Inquiry) actionsFor;

  const _InquiryTable({
    required this.inquiries,
    required this.onOpen,
    required this.actionsFor,
  });

  static const _gap = SizedBox(width: 16);

  @override
  Widget build(BuildContext context) {
    final headerStyle =
        AppTypography.caption.copyWith(color: AppColors.mutedForeground);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.surfaceSunken,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                SizedBox(width: 120, child: Text('Upit', style: headerStyle)),
                _gap,
                Expanded(flex: 3, child: Text('Klijent', style: headerStyle)),
                _gap,
                Expanded(flex: 3, child: Text('Period', style: headerStyle)),
                _gap,
                SizedBox(
                  width: 100,
                  child: Text('Budžet',
                      textAlign: TextAlign.right, style: headerStyle),
                ),
                _gap,
                SizedBox(
                  width: 76,
                  child: Text('Površine',
                      textAlign: TextAlign.right, style: headerStyle),
                ),
                _gap,
                SizedBox(width: 150, child: Text('Status', style: headerStyle)),
                _gap,
                SizedBox(
                  width: 200,
                  child: Text('Akcije',
                      textAlign: TextAlign.right, style: headerStyle),
                ),
              ],
            ),
          ),
          for (var i = 0; i < inquiries.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.borderSoft),
            _InquiryTableRow(
              inquiry: inquiries[i],
              onTap: () => onOpen(inquiries[i]),
              actions: actionsFor(inquiries[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _InquiryTableRow extends StatefulWidget {
  final Inquiry inquiry;
  final VoidCallback onTap;
  final Widget? actions;

  const _InquiryTableRow({
    required this.inquiry,
    required this.onTap,
    required this.actions,
  });

  @override
  State<_InquiryTableRow> createState() => _InquiryTableRowState();
}

class _InquiryTableRowState extends State<_InquiryTableRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final inquiry = widget.inquiry;
    final muted =
        AppTypography.caption.copyWith(color: AppColors.mutedForeground);
    final type = SrLabels.inquiryType(inquiry.inquiryType);
    final requester = SrLabels.requesterType(inquiry.requesterType);
    final client = inquiry.clientName ?? '—';
    final email = inquiry.contactEmail ?? '';
    final days = inquiry.days;
    final count = inquiry.unitCount;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: _hover ? AppColors.background : AppColors.surface,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#${inquiry.id}',
                          style: AppTypography.money.copyWith(fontSize: 15)),
                      if (type.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        SpecChip(label: type),
                      ],
                    ],
                  ),
                ),
                _InquiryTable._gap,
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelLarge),
                      if (requester.isNotEmpty)
                        Text(requester,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: muted),
                      if (email.isNotEmpty)
                        Text(email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: muted),
                    ],
                  ),
                ),
                _InquiryTable._gap,
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SrFormat.period(inquiry.startDate, inquiry.endDate),
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.foreground),
                      ),
                      if (days != null)
                        Text(SrFormat.daysLabel(days), style: muted),
                      if (inquiry.createdAt != null)
                        Text('podnet ${SrFormat.relative(inquiry.createdAt)}',
                            style: muted.copyWith(color: AppColors.subtle)),
                    ],
                  ),
                ),
                _InquiryTable._gap,
                SizedBox(
                  width: 100,
                  child: Text(
                    inquiry.budget == null
                        ? '—'
                        : SrFormat.money(inquiry.budget, 'EUR'),
                    textAlign: TextAlign.right,
                    style: AppTypography.money.copyWith(fontSize: 15),
                  ),
                ),
                _InquiryTable._gap,
                SizedBox(
                  width: 76,
                  child: Text(
                    count > 0 ? '$count' : '—',
                    textAlign: TextAlign.right,
                    style: AppTypography.money.copyWith(fontSize: 15),
                  ),
                ),
                _InquiryTable._gap,
                SizedBox(
                  width: 150,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:
                        InquiryStatusBadge(status: inquiry.status, dense: true),
                  ),
                ),
                _InquiryTable._gap,
                SizedBox(
                  width: 200,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: widget.actions ?? const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
