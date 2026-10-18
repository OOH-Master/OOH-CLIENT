import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../data/repository/inquiry_repository.dart';
import '../../domain/entities/inquiry.dart';
import '../blocs/inquiry_bloc.dart';
import '../widgets/inquiry_card.dart';
import '../widgets/inquiry_layout.dart';

class InquiryListPage extends StatelessWidget {
  const InquiryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = authState.user.role;

    return BlocProvider(
      create: (context) => InquiryBloc(context.read<InquiryRepository>())
        ..add(LoadInquiries(role)),
      child: _InquiryListView(role: role),
    );
  }
}

/// Grupe upita za brzi filter iznad liste.
enum _ListFilter { all, active, offer, finished }

class _InquiryListView extends StatefulWidget {
  final Role role;

  const _InquiryListView({required this.role});

  @override
  State<_InquiryListView> createState() => _InquiryListViewState();
}

class _InquiryListViewState extends State<_InquiryListView> {
  _ListFilter _filter = _ListFilter.all;
  List<Inquiry>? _last;

  bool get _isAdmin => widget.role == Role.admin;

  /// Pregled ponude je stranica brenda i agencije.
  bool get _canViewOffer =>
      widget.role == Role.brand || widget.role == Role.agency;

  String get _title => _isAdmin ? 'Svi upiti' : 'Moji upiti';

  bool _matches(Inquiry inquiry, _ListFilter filter) {
    switch (filter) {
      case _ListFilter.all:
        return true;
      case _ListFilter.active:
        return inquiry.status.isActive;
      case _ListFilter.offer:
        return inquiry.status == InquiryStatus.offerSent;
      case _ListFilter.finished:
        return inquiry.status.isFinished;
    }
  }

  String _filterLabel(_ListFilter filter) {
    switch (filter) {
      case _ListFilter.all:
        return 'Svi';
      case _ListFilter.active:
        return 'U toku';
      case _ListFilter.offer:
        return _isAdmin ? 'Ponuda poslata' : 'Ponuda stigla';
      case _ListFilter.finished:
        return 'Završeni';
    }
  }

  /// Najnoviji upiti prvi.
  List<Inquiry> _sorted(List<Inquiry> inquiries) {
    final list = [...inquiries];
    list.sort((a, b) {
      final da = a.createdAtDate;
      final db = b.createdAtDate;
      if (da != null && db != null && da != db) return db.compareTo(da);
      return b.id.compareTo(a.id);
    });
    return list;
  }

  void _reload() => context.read<InquiryBloc>().add(LoadInquiries(widget.role));

  /// Posle povratka sa detalja ili ponude lista se osvežava (status se menja).
  void _open(String location) {
    context.push(location).then((_) {
      if (mounted) _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return InquiryScaffold(
      title: _title,
      body: BlocBuilder<InquiryBloc, InquiryState>(
        builder: (context, state) {
          if (state is InquiriesLoaded) _last = _sorted(state.inquiries);
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
              Expanded(child: _buildList(inquiries)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<Inquiry> inquiries) {
    final wide = InquiryLayout.isWide(context);
    final visible = inquiries.where((i) => _matches(i, _filter)).toList();

    return LayoutBuilder(builder: (context, constraints) {
      final gutter = InquiryLayout.gutter(constraints.maxWidth, wide: wide);
      return RefreshIndicator(
        onRefresh: () async => _reload(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 32),
          children: [
            InquiryHeader(title: _title),
            if (inquiries.isEmpty)
              _emptyAll()
            else ...[
              _FilterChips(
                selected: _filter,
                labelFor: _filterLabel,
                countFor: (f) => inquiries.where((i) => _matches(i, f)).length,
                onSelected: (f) => setState(() => _filter = f),
              ),
              const SizedBox(height: 16),
              if (visible.isEmpty)
                EmptyState(
                  compact: true,
                  icon: Icons.filter_alt_off_outlined,
                  title: 'Nema upita u ovoj grupi',
                  action: TextButton(
                    onPressed: () => setState(() => _filter = _ListFilter.all),
                    child: const Text('Prikaži sve upite'),
                  ),
                )
              else
                InquiryCardGrid(
                  itemCount: visible.length,
                  itemBuilder: (context, index, fill) {
                    final inquiry = visible[index];
                    final offerReady = _canViewOffer &&
                        inquiry.status == InquiryStatus.offerSent;
                    return InquiryCard(
                      inquiry: inquiry,
                      fill: fill,
                      showClient: _isAdmin || widget.role == Role.agency,
                      onTap: () => _open('/app/inquiries/${inquiry.id}'),
                      onViewOffer: offerReady
                          ? () => _open('/app/inquiries/${inquiry.id}/offer')
                          : null,
                    );
                  },
                ),
            ],
          ],
        ),
      );
    });
  }

  Widget _emptyAll() {
    if (_isAdmin) {
      return const EmptyState(icon: Icons.inbox_outlined, title: 'Nema upita');
    }
    return EmptyState(
      icon: Icons.forward_to_inbox_outlined,
      title: 'Još nemate upita',
      action: FilledButton(
        onPressed: () => context.go('/app/discover'),
        child: const Text('Istraži površine'),
      ),
    );
  }
}

/// Grupe sa brojem upita: "U toku 3" (broj kao poseban, tiši tekst).
class _FilterChips extends StatelessWidget {
  final _ListFilter selected;
  final String Function(_ListFilter) labelFor;
  final int Function(_ListFilter) countFor;
  final ValueChanged<_ListFilter> onSelected;

  const _FilterChips({
    required this.selected,
    required this.labelFor,
    required this.countFor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in _ListFilter.values)
          ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(labelFor(filter)),
                const SizedBox(width: 6),
                Text(
                  '${countFor(filter)}',
                  style: TextStyle(
                    color: filter == selected
                        ? AppColors.primaryStrong
                        : AppColors.mutedForeground,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            selected: filter == selected,
            showCheckmark: false,
            onSelected: (_) => onSelected(filter),
          ),
      ],
    );
  }
}
