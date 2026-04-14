import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repository/availability_repository.dart';
import '../blocs/availability_bloc.dart';

class AvailabilityManagementPage extends StatelessWidget {
  const AvailabilityManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AvailabilityBloc(context.read<AvailabilityRepository>())
            ..add(LoadSlots()),
      child: const _AvailabilityManagementView(),
    );
  }
}

class _AvailabilityManagementView extends StatefulWidget {
  const _AvailabilityManagementView();

  @override
  State<_AvailabilityManagementView> createState() =>
      _AvailabilityManagementViewState();
}

class _AvailabilityManagementViewState
    extends State<_AvailabilityManagementView> {
  int? _selectedInventoryItemId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upravljanje dostupnoscu'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSlotDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Inventory item filter hint
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Text(
              'Prikazani su svi slotovi dostupnosti za vas inventar.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
            ),
          ),
          Expanded(
            child: BlocConsumer<AvailabilityBloc, AvailabilityState>(
              listener: (context, state) {
                if (state is AvailabilityActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                  context.read<AvailabilityBloc>().add(
                        LoadSlots(inventoryItemId: _selectedInventoryItemId),
                      );
                }
                if (state is AvailabilityError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.destructive,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AvailabilityLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AvailabilityLoaded) {
                  if (state.slots.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available,
                              size: 64, color: AppColors.mutedForeground),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Nema slotova dostupnosti',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.mutedForeground),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Dodajte slot koristecu dugme +',
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.mutedForeground),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AvailabilityBloc>().add(
                            LoadSlots(
                                inventoryItemId: _selectedInventoryItemId),
                          );
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: state.slots.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        return _buildSlotCard(context, state.slots[index]);
                      },
                    ),
                  );
                }

                if (state is AvailabilityError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: AppColors.destructive),
                        const SizedBox(height: AppSpacing.md),
                        Text(state.message),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton(
                          onPressed: () => context
                              .read<AvailabilityBloc>()
                              .add(LoadSlots()),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(BuildContext context, AvailabilitySlot slot) {
    final statusColor = _getStatusColor(slot.status);
    final statusLabel = _getStatusLabel(slot.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTypography.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Inventar #${slot.inventoryItemId}',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(
                      '${slot.startDate ?? '?'} - ${slot.endDate ?? '?'}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                if (slot.notes != null && slot.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    slot.notes!,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showSlotDialog(context, slot: slot);
              } else if (value == 'delete') {
                _confirmDelete(context, slot);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Izmeni')),
              const PopupMenuItem(value: 'delete', child: Text('Obrisi')),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return AppColors.success;
      case 'BOOKED':
        return AppColors.destructive;
      case 'MAINTENANCE':
        return AppColors.warning;
      case 'BLOCKED':
        return AppColors.mutedForeground;
      default:
        return AppColors.mutedForeground;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return 'Dostupno';
      case 'BOOKED':
        return 'Rezervisano';
      case 'MAINTENANCE':
        return 'Odrzavanje';
      case 'BLOCKED':
        return 'Blokirano';
      default:
        return status;
    }
  }

  void _showSlotDialog(BuildContext context, {AvailabilitySlot? slot}) {
    final isEditing = slot != null;
    DateTime? startDate = slot?.startDate != null
        ? DateTime.tryParse(slot!.startDate!)
        : null;
    DateTime? endDate =
        slot?.endDate != null ? DateTime.tryParse(slot!.endDate!) : null;
    String selectedStatus = slot?.status ?? 'AVAILABLE';
    final notesController = TextEditingController(text: slot?.notes ?? '');
    final inventoryIdController = TextEditingController(
      text: slot?.inventoryItemId.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Izmeni slot' : 'Novi slot dostupnosti'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isEditing)
                      TextField(
                        controller: inventoryIdController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'ID inventara',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                      ),
                    if (!isEditing)
                      const SizedBox(height: AppSpacing.md),
                    // Start date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Datum pocetka',
                        style: AppTypography.bodySmall,
                      ),
                      subtitle: Text(
                        startDate != null
                            ? _formatDate(startDate!)
                            : 'Nije odabrano',
                      ),
                      trailing: const Icon(Icons.calendar_today, size: 20),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() => startDate = picked);
                        }
                      },
                    ),
                    // End date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Datum zavrsetka',
                        style: AppTypography.bodySmall,
                      ),
                      subtitle: Text(
                        endDate != null
                            ? _formatDate(endDate!)
                            : 'Nije odabrano',
                      ),
                      trailing: const Icon(Icons.calendar_today, size: 20),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() => endDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'AVAILABLE', child: Text('Dostupno')),
                        DropdownMenuItem(
                            value: 'BOOKED', child: Text('Rezervisano')),
                        DropdownMenuItem(
                            value: 'MAINTENANCE',
                            child: Text('Odrzavanje')),
                        DropdownMenuItem(
                            value: 'BLOCKED', child: Text('Blokirano')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedStatus = v);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Napomene',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Otkazi'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    final data = <String, dynamic>{
                      'status': selectedStatus,
                    };
                    if (startDate != null) {
                      data['startDate'] = _formatDate(startDate!);
                    }
                    if (endDate != null) {
                      data['endDate'] = _formatDate(endDate!);
                    }
                    if (notesController.text.isNotEmpty) {
                      data['notes'] = notesController.text;
                    }
                    if (!isEditing) {
                      final invId =
                          int.tryParse(inventoryIdController.text);
                      if (invId != null) {
                        data['inventoryItemId'] = invId;
                      }
                      context
                          .read<AvailabilityBloc>()
                          .add(CreateSlot(data));
                    } else {
                      context
                          .read<AvailabilityBloc>()
                          .add(UpdateSlot(slot.id, data));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                  ),
                  child: Text(isEditing ? 'Sacuvaj' : 'Kreiraj'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, AvailabilitySlot slot) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Brisanje slota'),
          content: const Text(
              'Da li ste sigurni da zelite da obrisete ovaj slot?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Otkazi'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AvailabilityBloc>().add(
                      DeleteSlot(slot.id,
                          inventoryItemId: _selectedInventoryItemId),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive,
                foregroundColor: Colors.white,
              ),
              child: const Text('Obrisi'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
