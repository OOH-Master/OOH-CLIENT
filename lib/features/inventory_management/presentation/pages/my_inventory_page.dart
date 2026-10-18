import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../discover/data/dto/dto.dart';
import '../../data/repository/inventory_management_repository.dart';
import '../blocs/inventory_management_bloc.dart';
import '../widgets/bulk_action_toolbar.dart';
import '../widgets/inventory_filter_bar.dart';
import '../widgets/inventory_list_items.dart';

class MyInventoryPage extends StatelessWidget {
  const MyInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InventoryManagementBloc(context.read<InventoryManagementRepository>())
            ..add(LoadMyInventory()),
      child: const _MyInventoryView(),
    );
  }
}

class _MyInventoryView extends StatefulWidget {
  const _MyInventoryView();

  @override
  State<_MyInventoryView> createState() => _MyInventoryViewState();
}

class _MyInventoryViewState extends State<_MyInventoryView> {
  final TextEditingController _searchController = TextEditingController();

  /// Poslednja učitana lista: dok se lista ponovo učitava (posle brisanja ili
  /// promene statusa), ostaje na ekranu sa trakom napretka umesto praznog ekrana.
  InventoryManagementLoaded? _last;

  /// Pretraga, status i redosled pre ponovnog učitavanja; vraćaju se kada lista
  /// stigne, jer učitavanje u bloku poništava filtere.
  (String, String?, String)? _restore;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  InventoryManagementBloc get _bloc => context.read<InventoryManagementBloc>();

  Future<void> _openForm([InventoryItemDto? item]) async {
    final bloc = _bloc;
    if (item == null) {
      await context.push('/app/inventory/create');
    } else {
      await context.push('/app/inventory/${item.id}/edit',
          extra: item.toJson());
    }
    // Lista se osvežava posle povratka sa forme, da nova ili izmenjena površina
    // bude odmah vidljiva.
    if (mounted) bloc.add(LoadMyInventory());
  }

  void _onRowAction(
      String action, InventoryItemDto item, AppLocalizations l10n) {
    switch (action) {
      case 'edit':
        _openForm(item);
      case 'toggle':
        final active = InventoryStatus.isActive(item.status);
        _bloc.add(BulkUpdateStatus([item.id], active ? 'DISABLED' : 'ACTIVE'));
      case 'delete':
        _showDeleteDialog(item, l10n);
    }
  }

  void _resetFilters() {
    _searchController.clear();
    _bloc.add(SearchInventory(''));
    _bloc.add(FilterByStatus(null));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: wide
          ? null
          : AppBar(
              title: Text(l10n.myInventory),
              actions: [
                BlocBuilder<InventoryManagementBloc, InventoryManagementState>(
                  builder: (context, state) {
                    if (state is! InventoryManagementLoaded ||
                        state.filteredItems.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final allSelected =
                        state.selectedIds.length == state.filteredItems.length;
                    return IconButton(
                      icon: Icon(allSelected
                          ? Icons.deselect_rounded
                          : Icons.select_all_rounded),
                      tooltip: allSelected ? 'Poništi izbor' : 'Izaberi sve',
                      onPressed: () => _bloc
                          .add(allSelected ? ClearSelection() : SelectAll()),
                    );
                  },
                ),
              ],
            ),
      floatingActionButton: wide
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Dodaj površinu'),
            ),
      body: BlocConsumer<InventoryManagementBloc, InventoryManagementState>(
        listener: (context, state) {
          final last = _last;
          if (state is InventoryManagementLoading && last != null) {
            _restore = (last.searchQuery, last.statusFilter, last.sortBy);
          } else if (state is InventoryManagementLoaded && _restore != null) {
            final (query, status, sort) = _restore!;
            _restore = null;
            if (query.isNotEmpty) _bloc.add(SearchInventory(query));
            if (status != null) _bloc.add(FilterByStatus(status));
            if (sort != state.sortBy) _bloc.add(SortInventory(sort));
          }
          if (state is InventoryFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is InventoryManagementError && _last != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.destructive,
              ),
            );
          }
        },
        buildWhen: (previous, current) => current is! InventoryFormSuccess,
        builder: (context, state) {
          if (state is InventoryManagementLoaded) _last = state;
          final busy = state is InventoryManagementLoading ||
              state is InventoryManagementInitial;
          final data = state is InventoryManagementLoaded ? state : _last;

          return LayoutBuilder(
            builder: (context, constraints) {
              final side = wide ? 32.0 : 16.0;
              final gutter = math.max(side, (constraints.maxWidth - 1240) / 2);

              if (data == null) {
                if (state is InventoryManagementError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () => _bloc.add(LoadMyInventory()),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              }

              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async => _bloc.add(LoadMyInventory()),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                              gutter, wide ? 0 : 16, gutter, 0),
                          sliver: SliverToBoxAdapter(
                            child: _buildTop(data, wide, l10n),
                          ),
                        ),
                        ..._buildList(data, constraints.maxWidth - 2 * gutter,
                            gutter, l10n),
                        const SliverToBoxAdapter(child: SizedBox(height: 96)),
                      ],
                    ),
                  ),
                  if (busy)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTop(
      InventoryManagementLoaded state, bool wide, AppLocalizations l10n) {
    final items = state.items;
    final active =
        items.where((i) => InventoryStatus.isActive(i.status)).length;
    final cities = items
        .map((i) => i.city?.name)
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .toSet()
        .length;

    final String? subtitle = items.isEmpty
        ? null
        : '${SrFormat.count(items.length, 'površina', 'površine', 'površina')}'
            '${cities > 0 ? ' u ${SrFormat.count(cities, 'gradu', 'grada', 'gradova')}' : ''}'
            ', ${SrFormat.count(active, 'aktivna', 'aktivne', 'aktivnih')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (wide)
          PageHeader(
            title: l10n.myInventory,
            subtitle: subtitle,
            padding: const EdgeInsets.only(top: 28, bottom: 22),
            actions: [
              FilledButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Dodaj površinu'),
              ),
            ],
          )
        else if (subtitle != null) ...[
          Text(subtitle,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.mutedForeground)),
          const SizedBox(height: 14),
        ],
        if (items.isNotEmpty) ...[
          _KpiStrip(items: items),
          const SizedBox(height: 16),
          InventoryFilterBar(
            searchController: _searchController,
            activeStatusFilter: state.statusFilter,
            currentSort: state.sortBy,
            counts: {
              null: items.length,
              'ACTIVE': active,
              'DISABLED': items.length - active,
            },
            onSearchChanged: (query) => _bloc.add(SearchInventory(query)),
            onStatusFilterChanged: (status) =>
                _bloc.add(FilterByStatus(status)),
            onSortChanged: (sort) => _bloc.add(SortInventory(sort)),
          ),
        ],
        if (state.selectedIds.isNotEmpty) ...[
          const SizedBox(height: 12),
          BulkActionToolbar(
            selectedCount: state.selectedIds.length,
            onActivateAll: () => _bloc
                .add(BulkUpdateStatus(state.selectedIds.toList(), 'ACTIVE')),
            onDeactivateAll: () => _bloc
                .add(BulkUpdateStatus(state.selectedIds.toList(), 'DISABLED')),
            onDeleteAll: () =>
                _showBulkDeleteDialog(state.selectedIds.toList(), l10n),
            onClearSelection: () => _bloc.add(ClearSelection()),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildList(InventoryManagementLoaded state, double contentWidth,
      double gutter, AppLocalizations l10n) {
    final padding = EdgeInsets.symmetric(horizontal: gutter);

    if (state.items.isEmpty) {
      return [
        SliverPadding(
          padding: padding,
          sliver: SliverToBoxAdapter(
            child: SectionCard(
              child: EmptyState(
                icon: Icons.view_quilt_outlined,
                title: 'Još nema površina',
                message: 'Dodajte prvu oglasnu površinu.',
                action: FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Dodaj površinu'),
                ),
              ),
            ),
          ),
        ),
      ];
    }

    if (state.filteredItems.isEmpty) {
      return [
        SliverPadding(
          padding: padding,
          sliver: SliverToBoxAdapter(
            child: SectionCard(
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Nema površina za ovaj izbor',
                message: 'Promenite pretragu ili filter statusa.',
                action: OutlinedButton(
                  onPressed: _resetFilters,
                  child: const Text('Poništi filtere'),
                ),
              ),
            ),
          ),
        ),
      ];
    }

    final items = state.filteredItems;
    final selectionMode = state.selectedIds.isNotEmpty;

    if (contentWidth >= 860) {
      final selectedCount =
          items.where((i) => state.selectedIds.contains(i.id)).length;
      final bool? allSelected = selectedCount == 0
          ? false
          : (selectedCount == items.length ? true : null);

      return [
        SliverPadding(
          padding: padding,
          sliver: DecoratedSliver(
            decoration: AppDecorations.card(),
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: InventoryTableHeader(
                    allSelected: allSelected,
                    onSelectAll: (_) => _bloc.add(
                        allSelected == true ? ClearSelection() : SelectAll()),
                  ),
                ),
                SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.borderSoft),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return InventoryTableRow(
                      key: ValueKey(item.id),
                      item: item,
                      selected: state.selectedIds.contains(item.id),
                      onToggleSelect: () => _bloc.add(ToggleSelection(item.id)),
                      onOpen: () => _openForm(item),
                      onAction: (a) => _onRowAction(a, item, l10n),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: padding,
        sliver: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return InventoryCard(
              key: ValueKey(item.id),
              item: item,
              selected: state.selectedIds.contains(item.id),
              selectionMode: selectionMode,
              onToggleSelect: () => _bloc.add(ToggleSelection(item.id)),
              onOpen: () => _openForm(item),
              onAction: (a) => _onRowAction(a, item, l10n),
            );
          },
        ),
      ),
    ];
  }

  void _showDeleteDialog(InventoryItemDto item, AppLocalizations l10n) {
    final view = InventoryView(item);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Obrisati površinu?'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: AppDecorations.sunken(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: UnitLine(
                    imageUrl: item.assetUrl,
                    digital: view.digital,
                    code: view.code,
                    title: view.title,
                    subtitle: view.place,
                    compact: true,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                  'Površina se uklanja iz pretrage i iz budućih ponuda. Ova radnja se ne može poništiti.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              _bloc.add(DeleteInventoryItem(item.id));
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showBulkDeleteDialog(List<int> ids, AppLocalizations l10n) {
    final label =
        SrFormat.count(ids.length, 'površinu', 'površine', 'površina');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Obrisati $label?'),
        content: const SizedBox(
          width: 440,
          child: Text(
              'Izabrane površine se uklanjaju iz pretrage i iz budućih ponuda. Ova radnja se ne može poništiti.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              for (final id in ids) {
                _bloc.add(DeleteInventoryItem(id));
              }
              _bloc.add(ClearSelection());
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

/// Četiri brza podatka o inventaru: ukupno, aktivne, digitalne, bez cene.
class _KpiStrip extends StatelessWidget {
  final List<InventoryItemDto> items;

  const _KpiStrip({required this.items});

  @override
  Widget build(BuildContext context) {
    final total = items.length;
    final active =
        items.where((i) => InventoryStatus.isActive(i.status)).length;
    final digital = items.where((i) => InventoryView(i).digital).length;
    final noPrice = items.where((i) => i.pricePerCycle == null).length;

    return StatStrip(items: [
      StatItem('Površine', '$total',
          note: SrFormat.count(
              total - active, 'neaktivna', 'neaktivne', 'neaktivnih')),
      StatItem('Aktivne u pretrazi', '$active', note: 'od $total'),
      StatItem('Digitalne', '$digital',
          note: SrFormat.count(
              total - digital, 'statična', 'statične', 'statičnih')),
      StatItem('Bez cene', '$noPrice'),
    ]);
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.cloud_off_rounded,
      title: 'Inventar trenutno nije dostupan',
      message: message,
      action: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('Pokušaj ponovo'),
      ),
    );
  }
}
