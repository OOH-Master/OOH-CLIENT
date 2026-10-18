import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../discover/data/dto/dto.dart';
import '../../../inventory_management/data/repository/inventory_management_repository.dart';
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

/// Naziv, šifra, mesto i sličica površine za termin.
class _UnitInfo {
  final InventoryItemDto? unit;
  final int id;

  const _UnitInfo(this.unit, this.id);

  String? get code {
    final c = unit?.vendorInventoryId?.trim();
    return (c == null || c.isEmpty) ? null : c;
  }

  String get title {
    final n = unit?.siteName?.trim();
    if (n != null && n.isNotEmpty) return n;
    return code ?? 'Površina #$id';
  }

  String get place =>
      unit == null ? '' : SrLabels.place(unit!.city?.name, unit!.country?.name);

  String? get imageUrl => unit?.assetUrl;

  bool get digital => SrLabels.isDigital(unit?.unitType?.name);

  /// Stavka padajuće liste: šifra (siva) pa naziv, kao u redu površine.
  Widget option() {
    final c = code;
    return Row(
      children: [
        if (c != null && c != title) ...[
          Text(
            c,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.mutedForeground,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
      ],
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

  /// Površine vlasnika, za nazive i sličice termina; bez njih ostaje broj površine.
  List<InventoryItemDto> _units = const [];
  Map<int, InventoryItemDto> _unitsById = const {};

  /// Poslednji učitani termini; ostaju vidljivi dok se lista osvežava.
  List<AvailabilitySlot>? _lastSlots;

  static const _statuses = ['AVAILABLE', 'BOOKED', 'MAINTENANCE', 'BLOCKED'];

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    try {
      final items =
          await context.read<InventoryManagementRepository>().getMyInventory();
      if (!mounted) return;
      items.sort((a, b) => _UnitInfo(a, a.id)
          .title
          .toLowerCase()
          .compareTo(_UnitInfo(b, b.id).title.toLowerCase()));
      setState(() {
        _units = items;
        _unitsById = {for (final i in items) i.id: i};
      });
    } catch (_) {
      // Termini se i dalje prikazuju, samo sa brojem površine.
    }
  }

  _UnitInfo _unit(int id) => _UnitInfo(_unitsById[id], id);

  void _filterBy(int? id) {
    setState(() => _selectedInventoryItemId = id);
    context.read<AvailabilityBloc>().add(LoadSlots(inventoryItemId: id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: wide ? null : AppBar(title: const Text('Dostupnost')),
      floatingActionButton: wide
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showSlotDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novi termin'),
            ),
      body: BlocConsumer<AvailabilityBloc, AvailabilityState>(
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
        buildWhen: (previous, current) => current is! AvailabilityActionSuccess,
        builder: (context, state) {
          if (state is AvailabilityLoaded) {
            _lastSlots = [
              ...state.slots
            ]..sort((a, b) => (a.startDate ?? '').compareTo(b.startDate ?? ''));
          }
          final slots = _lastSlots;
          final busy =
              state is AvailabilityLoading || state is AvailabilityInitial;

          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final side = wide ? 32.0 : 16.0;
                  final gutter =
                      math.max(side, (constraints.maxWidth - 1240) / 2);
                  final width = constraints.maxWidth - 2 * gutter;
                  return RefreshIndicator(
                    onRefresh: () async => context.read<AvailabilityBloc>().add(
                        LoadSlots(inventoryItemId: _selectedInventoryItemId)),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                          gutter, wide ? 0 : 16, gutter, 96),
                      children: [
                        if (wide)
                          PageHeader(
                            title: 'Dostupnost',
                            padding: const EdgeInsets.only(top: 28, bottom: 22),
                            actions: [
                              FilledButton.icon(
                                onPressed: () => _showSlotDialog(context),
                                icon: const Icon(Icons.add_rounded, size: 20),
                                label: const Text('Novi termin'),
                              ),
                            ],
                          ),
                        _buildToolbar(slots, l10n),
                        const SizedBox(height: 16),
                        _buildList(state, slots, width, l10n),
                      ],
                    ),
                  );
                },
              ),
              if (busy && slots != null)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToolbar(List<AvailabilitySlot>? slots, AppLocalizations l10n) {
    final counts = <String, int>{};
    for (final s in slots ?? const <AvailabilitySlot>[]) {
      counts.update(s.status.toUpperCase(), (v) => v + 1, ifAbsent: () => 1);
    }

    final filter = DropdownButtonFormField<int?>(
      initialValue: _selectedInventoryItemId,
      isExpanded: true,
      decoration: const InputDecoration(
        isDense: true,
        prefixIcon: Icon(Icons.view_quilt_outlined, size: 20),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('Sve površine')),
        for (final u in _units)
          DropdownMenuItem<int?>(
            value: u.id,
            child: _UnitInfo(u, u.id).option(),
          ),
      ],
      onChanged: _units.isEmpty ? null : _filterBy,
    );

    final summary = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in _statuses)
          StatusPill(
            label: '${_statusLabel(s, l10n)} ${counts[s] ?? 0}',
            tone: _statusTone(s),
          ),
      ],
    );

    return DecoratedBox(
      decoration: AppDecorations.card(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 860) {
              return Row(
                children: [
                  SizedBox(width: 340, child: filter),
                  const SizedBox(width: 16),
                  Expanded(child: summary),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [filter, const SizedBox(height: 12), summary],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(AvailabilityState state, List<AvailabilitySlot>? slots,
      double width, AppLocalizations l10n) {
    if (slots == null) {
      if (state is AvailabilityError) {
        return SectionCard(
          child: EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Termini trenutno nisu dostupni',
            message: state.message,
            action: OutlinedButton.icon(
              onPressed: () => context
                  .read<AvailabilityBloc>()
                  .add(LoadSlots(inventoryItemId: _selectedInventoryItemId)),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.retry),
            ),
          ),
        );
      }
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (slots.isEmpty) {
      return SectionCard(
        child: EmptyState(
          icon: Icons.event_available_outlined,
          title: _selectedInventoryItemId == null
              ? 'Još nema termina'
              : 'Nema termina za ovu površinu',
          message:
              'Dodajte termin kada je površina zakupljena, na održavanju ili blokirana.',
          action: FilledButton.icon(
            onPressed: () => _showSlotDialog(context),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Novi termin'),
          ),
        ),
      );
    }

    final table = width >= 860;
    final rows = <Widget>[];
    for (var i = 0; i < slots.length; i++) {
      final slot = slots[i];
      if (table && i > 0) {
        rows.add(const Divider(height: 1, color: AppColors.borderSoft));
      }
      rows.add(_SlotEntry(
        slot: slot,
        unit: _unit(slot.inventoryItemId),
        table: table,
        statusLabel: _statusLabel(slot.status, l10n),
        statusTone: _statusTone(slot.status),
        onEdit: () => _showSlotDialog(context, slot: slot),
        onDelete: () => _confirmDelete(context, slot),
      ));
      if (!table) rows.add(const SizedBox(height: 12));
    }

    if (!table) return Column(children: rows);

    final head =
        AppTypography.labelSmall.copyWith(color: AppColors.mutedForeground);
    return DecoratedBox(
      decoration: AppDecorations.card(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 11, 8, 11),
            decoration: const BoxDecoration(
              color: AppColors.surfaceSunken,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(flex: 5, child: Text('Površina', style: head)),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: Text('Period', style: head)),
                SizedBox(width: 150, child: Text('Status', style: head)),
                Expanded(flex: 3, child: Text('Napomena', style: head)),
                const SizedBox(width: 48),
              ],
            ),
          ),
          ...rows,
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  PillTone _statusTone(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return PillTone.success;
      case 'BOOKED':
        return PillTone.primary;
      case 'MAINTENANCE':
        return PillTone.violet;
      default:
        return PillTone.neutral;
    }
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return l10n.availabilityStatusAvailable;
      case 'BOOKED':
        return l10n.availabilityStatusBooked;
      case 'MAINTENANCE':
        return l10n.availabilityStatusMaintenance;
      case 'BLOCKED':
        return l10n.availabilityStatusBlocked;
      default:
        return status;
    }
  }

  void _showSlotDialog(BuildContext context, {AvailabilitySlot? slot}) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = slot != null;
    DateTime? startDate =
        slot?.startDate != null ? DateTime.tryParse(slot!.startDate!) : null;
    DateTime? endDate =
        slot?.endDate != null ? DateTime.tryParse(slot!.endDate!) : null;
    String selectedStatus = slot?.status ?? 'AVAILABLE';
    int? selectedUnitId = _selectedInventoryItemId;
    final notesController = TextEditingController(text: slot?.notes ?? '');
    final inventoryIdController = TextEditingController(
      text: slot?.inventoryItemId.toString() ?? '',
    );

    Future<DateTime?> pick(BuildContext ctx, DateTime? current) {
      return showDatePicker(
        context: ctx,
        initialDate: current ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime(2030),
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final period = (startDate != null && endDate != null)
                ? SrFormat.daysLabel(endDate!.difference(startDate!).inDays + 1)
                : '';
            return AlertDialog(
              title: Text(isEditing ? 'Izmena termina' : 'Novi termin'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isEditing)
                        _DialogUnit(unit: _unit(slot.inventoryItemId))
                      else if (_units.isNotEmpty)
                        DropdownButtonFormField<int>(
                          initialValue: selectedUnitId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Površina',
                            prefixIcon:
                                Icon(Icons.view_quilt_outlined, size: 20),
                          ),
                          items: [
                            for (final u in _units)
                              DropdownMenuItem(
                                value: u.id,
                                child: _UnitInfo(u, u.id).option(),
                              ),
                          ],
                          onChanged: (v) =>
                              setDialogState(() => selectedUnitId = v),
                        )
                      else
                        TextField(
                          controller: inventoryIdController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Broj površine (ID)',
                            prefixIcon:
                                Icon(Icons.view_quilt_outlined, size: 20),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _DateBox(
                              label: 'Od',
                              value: startDate,
                              onTap: () async {
                                final picked =
                                    await pick(dialogContext, startDate);
                                if (picked != null) {
                                  setDialogState(() => startDate = picked);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DateBox(
                              label: 'Do',
                              value: endDate,
                              onTap: () async {
                                final picked = await pick(
                                    dialogContext, endDate ?? startDate);
                                if (picked != null) {
                                  setDialogState(() => endDate = picked);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      if (period.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Trajanje: $period',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.mutedForeground),
                        ),
                      ],
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: [
                          for (final s in _statuses)
                            DropdownMenuItem(
                              value: s,
                              child: Text(_statusLabel(s, l10n)),
                            ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedStatus = v);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Napomena',
                          hintText: 'npr. zakup za kampanju, servis ekrana',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Otkaži'),
                ),
                FilledButton(
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
                      final invId = selectedUnitId ??
                          int.tryParse(inventoryIdController.text);
                      if (invId != null) {
                        data['inventoryItemId'] = invId;
                      }
                      context.read<AvailabilityBloc>().add(CreateSlot(data));
                    } else {
                      context
                          .read<AvailabilityBloc>()
                          .add(UpdateSlot(slot.id, data));
                    }
                  },
                  child: Text(isEditing ? 'Sačuvaj' : 'Dodaj termin'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, AvailabilitySlot slot) {
    final unit = _unit(slot.inventoryItemId);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Obrisati termin?'),
          content: SizedBox(
            width: 420,
            child: Text(
              '${unit.title}, ${SrFormat.period(slot.startDate, slot.endDate)}. Ova radnja se ne može poništiti.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Otkaži'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AvailabilityBloc>().add(
                      DeleteSlot(slot.id,
                          inventoryItemId: _selectedInventoryItemId),
                    );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.destructive,
                foregroundColor: Colors.white,
              ),
              child: const Text('Obriši'),
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

/// Jedan termin: kao red tabele na širokom ekranu, kao kartica na užem.
class _SlotEntry extends StatelessWidget {
  final AvailabilitySlot slot;
  final _UnitInfo unit;
  final bool table;
  final String statusLabel;
  final PillTone statusTone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SlotEntry({
    required this.slot,
    required this.unit,
    required this.table,
    required this.statusLabel,
    required this.statusTone,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final days =
        SrFormat.daysLabel(SrFormat.days(slot.startDate, slot.endDate));
    final period = (slot.startDate == null && slot.endDate == null)
        ? 'Bez datuma'
        : SrFormat.period(slot.startDate, slot.endDate);
    final notes = slot.notes?.trim() ?? '';

    final unitBlock = Row(
      children: [
        UnitThumb(
          imageUrl: unit.imageUrl,
          width: 64,
          height: 46,
          digital: unit.digital,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(unit.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge),
              Row(
                children: [
                  if (unit.code != null && unit.code != unit.title) ...[
                    Text(
                      unit.code!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.text2,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      unit.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.mutedForeground),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final periodBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(period,
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.foreground)),
        if (days.isNotEmpty)
          Text(days,
              style: AppTypography.caption
                  .copyWith(color: AppColors.mutedForeground)),
      ],
    );

    final menu = PopupMenuButton<String>(
      tooltip: 'Akcije',
      icon: const Icon(Icons.more_horiz_rounded, color: AppColors.text2),
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (_) {
        final l10n = AppLocalizations.of(context)!;
        return [
          PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
          PopupMenuItem(
            value: 'delete',
            child: Text(l10n.delete,
                style: const TextStyle(color: AppColors.destructive)),
          ),
        ];
      },
    );

    final pill = StatusPill(label: statusLabel, tone: statusTone, dense: true);

    if (table) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            child: Row(
              children: [
                Expanded(flex: 5, child: unitBlock),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: periodBlock),
                SizedBox(
                  width: 150,
                  child: Align(alignment: Alignment.centerLeft, child: pill),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    notes.isEmpty ? '—' : notes,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                        color:
                            notes.isEmpty ? AppColors.subtle : AppColors.text2),
                  ),
                ),
                SizedBox(width: 48, child: menu),
              ],
            ),
          ),
        ),
      );
    }

    return SectionCard(
      onTap: onEdit,
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: unitBlock), menu]),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [Expanded(child: periodBlock), pill],
            ),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTypography.bodySmall.copyWith(color: AppColors.text2)),
            ),
          ],
        ],
      ),
    );
  }
}

class _DialogUnit extends StatelessWidget {
  final _UnitInfo unit;

  const _DialogUnit({required this.unit});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppDecorations.sunken(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: UnitLine(
          imageUrl: unit.imageUrl,
          digital: unit.digital,
          code: unit.code,
          title: unit.title,
          subtitle: unit.place,
          compact: true,
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateBox(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.event_outlined, size: 20),
        ),
        child: Text(
          value == null ? '' : SrFormat.date(value),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
        ),
      ),
    );
  }
}
