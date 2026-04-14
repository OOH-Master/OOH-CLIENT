import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../discover/data/dto/dto.dart';
import '../../data/repository/inventory_management_repository.dart';
import '../blocs/inventory_management_bloc.dart';
import '../widgets/bulk_action_toolbar.dart';
import '../widgets/inventory_filter_bar.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.myInventory),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          BlocBuilder<InventoryManagementBloc, InventoryManagementState>(
            builder: (context, state) {
              if (state is InventoryManagementLoaded && state.filteredItems.isNotEmpty) {
                final allSelected = state.selectedIds.length == state.filteredItems.length;
                return IconButton(
                  icon: Icon(
                    allSelected ? Icons.deselect : Icons.select_all,
                    color: AppColors.foreground,
                  ),
                  onPressed: () {
                    if (allSelected) {
                      context.read<InventoryManagementBloc>().add(ClearSelection());
                    } else {
                      context.read<InventoryManagementBloc>().add(SelectAll());
                    }
                  },
                  tooltip: allSelected ? 'Ponisti selekciju' : 'Izaberi sve',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/app/inventory/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<InventoryManagementBloc, InventoryManagementState>(
        listener: (context, state) {
          if (state is InventoryFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is InventoryManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InventoryManagementError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message, style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<InventoryManagementBloc>().add(LoadMyInventory()),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state is InventoryManagementLoaded) {
            return Column(
              children: [
                // Filter bar
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: InventoryFilterBar(
                    searchController: _searchController,
                    activeStatusFilter: state.statusFilter,
                    currentSort: state.sortBy,
                    onSearchChanged: (query) {
                      context.read<InventoryManagementBloc>().add(SearchInventory(query));
                    },
                    onStatusFilterChanged: (status) {
                      context.read<InventoryManagementBloc>().add(FilterByStatus(status));
                    },
                    onSortChanged: (sort) {
                      context.read<InventoryManagementBloc>().add(SortInventory(sort));
                    },
                  ),
                ),
                // Bulk action toolbar
                if (state.selectedIds.isNotEmpty)
                  BulkActionToolbar(
                    selectedCount: state.selectedIds.length,
                    onActivateAll: () {
                      context.read<InventoryManagementBloc>().add(
                            BulkUpdateStatus(state.selectedIds.toList(), 'ACTIVE'),
                          );
                    },
                    onDeactivateAll: () {
                      context.read<InventoryManagementBloc>().add(
                            BulkUpdateStatus(state.selectedIds.toList(), 'DISABLED'),
                          );
                    },
                    onDeleteAll: () {
                      _showBulkDeleteDialog(context, state.selectedIds.toList(), l10n);
                    },
                    onClearSelection: () {
                      context.read<InventoryManagementBloc>().add(ClearSelection());
                    },
                  ),
                // Items list
                Expanded(
                  child: state.filteredItems.isEmpty
                      ? _buildEmptyState(context, l10n, state.items.isEmpty)
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<InventoryManagementBloc>().add(LoadMyInventory());
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            itemCount: state.filteredItems.length,
                            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              return _buildItemCard(
                                context,
                                state.filteredItems[index],
                                l10n,
                                isSelected: state.selectedIds.contains(state.filteredItems[index].id),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n, bool noItems) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            noItems ? Icons.inventory : Icons.search_off,
            size: 64,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            noItems ? l10n.noInventoryItems : 'Nema rezultata pretrage',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          if (noItems) ...[
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () => context.push('/app/inventory/create'),
              icon: const Icon(Icons.add),
              label: Text(l10n.addInventory),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    InventoryItemDto item,
    AppLocalizations l10n, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onLongPress: () {
        context.read<InventoryManagementBloc>().add(ToggleSelection(item.id));
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Selection checkbox (visible when any items are selected)
            BlocBuilder<InventoryManagementBloc, InventoryManagementState>(
              builder: (context, state) {
                if (state is InventoryManagementLoaded && state.selectedIds.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () {
                        context.read<InventoryManagementBloc>().add(ToggleSelection(item.id));
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Image placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: item.assetUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Image.network(
                        item.assetUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.image, color: AppColors.mutedForeground),
                      ),
                    )
                  : Icon(Icons.image, color: AppColors.mutedForeground),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.siteName ?? 'Item #${item.id}',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                      // Status badge
                      if (item.status != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item.status!).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            _getStatusLabel(item.status!),
                            style: AppTypography.caption.copyWith(
                              color: _getStatusColor(item.status!),
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (item.fullAddress != null)
                    Text(
                      item.fullAddress!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (item.pricePerCycle != null)
                    Text(
                      '${item.currency ?? '\u20AC'}${item.pricePerCycle!.toStringAsFixed(0)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            // Actions
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/app/inventory/${item.id}/edit');
                } else if (value == 'delete') {
                  _showDeleteDialog(context, item, l10n);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.editInventory)),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(l10n.delete, style: TextStyle(color: AppColors.destructive)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'AVAILABLE':
        return AppColors.success;
      case 'DISABLED':
      case 'INACTIVE':
        return AppColors.mutedForeground;
      case 'BOOKED':
        return AppColors.warning;
      default:
        return AppColors.mutedForeground;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'AVAILABLE':
        return 'Aktivno';
      case 'DISABLED':
      case 'INACTIVE':
        return 'Neaktivno';
      case 'BOOKED':
        return 'Rezervisano';
      default:
        return status;
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    InventoryItemDto item,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteInventory),
        content: Text(l10n.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<InventoryManagementBloc>().add(DeleteInventoryItem(item.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showBulkDeleteDialog(
    BuildContext context,
    List<int> ids,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Brisanje stavki'),
        content: Text('Da li ste sigurni da zelite da obrisete ${ids.length} stavki?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              for (final id in ids) {
                context.read<InventoryManagementBloc>().add(DeleteInventoryItem(id));
              }
              context.read<InventoryManagementBloc>().add(ClearSelection());
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
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
