import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../discover/data/dto/dto.dart';
import '../../data/repository/admin_config_repository.dart';
import '../blocs/admin_config_bloc.dart';

class AdminConfigPage extends StatelessWidget {
  const AdminConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminConfigBloc(context.read<AdminConfigRepository>())
            ..add(LoadConfigTab('countries')),
      child: const _AdminConfigView(),
    );
  }
}

/// Šifarnik: naziv kartice, jednina za dijaloge, ikonica (polja dijaloga i
/// prazno stanje) i srpski prikaz vrednosti.
class _DictionaryKind {
  final String type;
  final String tab;
  final String singular;
  final IconData icon;
  final String Function(String?) display;

  const _DictionaryKind(
      this.type, this.tab, this.singular, this.icon, this.display);
}

const _kinds = [
  _DictionaryKind(
      'countries', 'Države', 'država', Icons.flag_outlined, SrLabels.country),
  _DictionaryKind(
      'cities', 'Gradovi', 'grad', Icons.location_city_outlined, SrLabels.city),
  _DictionaryKind('unitTypes', 'Tipovi površina', 'tip površine',
      Icons.category_outlined, SrLabels.unitType),
  _DictionaryKind('mediaFormats', 'Formati', 'format',
      Icons.crop_landscape_rounded, SrLabels.format),
  _DictionaryKind('venueTypes', 'Tipovi lokacija', 'tip lokacije',
      Icons.place_outlined, SrLabels.venue),
];

class _AdminConfigView extends StatefulWidget {
  const _AdminConfigView();

  @override
  State<_AdminConfigView> createState() => _AdminConfigViewState();
}

class _AdminConfigViewState extends State<_AdminConfigView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _query = '';

  static final _tabs = _kinds.map((k) => k.type).toList();

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  _DictionaryKind get _kind => _kinds[_tabController.index];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _searchController.clear();
      setState(() => _query = '');
      context
          .read<AdminConfigBloc>()
          .add(LoadConfigTab(_tabs[_tabController.index]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final tabBar = TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: AppColors.foreground,
      unselectedLabelColor: AppColors.mutedForeground,
      indicatorColor: AppColors.primary,
      tabs: [for (final k in _kinds) Tab(text: k.tab)],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: wide
          ? null
          : AppBar(
              title: Text(l10n.configManagement),
              bottom: tabBar,
            ),
      floatingActionButton: wide
          ? null
          : FloatingActionButton(
              onPressed: () => _showCreateDialog(_tabs[_tabController.index]),
              tooltip: 'Dodaj stavku',
              child: const Icon(Icons.add_rounded),
            ),
      body: BlocConsumer<AdminConfigBloc, AdminConfigState>(
        listener: (context, state) {
          if (state is AdminConfigCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        buildWhen: (previous, current) => current is! AdminConfigCreateSuccess,
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final side = wide ? 32.0 : 16.0;
              final gutter = math.max(side, (constraints.maxWidth - 1240) / 2);
              return ListView(
                padding: EdgeInsets.fromLTRB(gutter, wide ? 0 : 16, gutter, 96),
                children: [
                  if (wide)
                    PageHeader(
                      title: l10n.configManagement,
                      padding: const EdgeInsets.only(top: 28, bottom: 22),
                      actions: [
                        FilledButton.icon(
                          onPressed: () =>
                              _showCreateDialog(_tabs[_tabController.index]),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: Text('Nova stavka: ${_kind.singular}'),
                        ),
                      ],
                    ),
                  DecoratedBox(
                    decoration: AppDecorations.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (wide)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                            child: tabBar,
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: _buildSearchRow(state),
                        ),
                        _buildContent(state),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchRow(AdminConfigState state) {
    final count = state is AdminConfigLoaded ? state.items.length : null;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Pretraži: ${_kind.tab.toLowerCase()}',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 16),
          Text(
            SrFormat.count(count, 'stavka', 'stavke', 'stavki'),
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ],
    );
  }

  Widget _buildContent(AdminConfigState state) {
    if (state is AdminConfigError) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Šifarnik trenutno nije dostupan',
        message: state.message,
        compact: true,
        action: OutlinedButton.icon(
          onPressed: () => context
              .read<AdminConfigBloc>()
              .add(LoadConfigTab(_tabs[_tabController.index])),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: Text(l10n.retry),
        ),
      );
    }
    if (state is! AdminConfigLoaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 56),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final kind =
        _kinds.firstWhere((k) => k.type == state.type, orElse: () => _kind);
    final items = _query.isEmpty
        ? state.items
        : state.items
            .where((i) =>
                i.name.toLowerCase().contains(_query) ||
                kind.display(i.name).toLowerCase().contains(_query))
            .toList();

    if (state.items.isEmpty) {
      return EmptyState(
        icon: kind.icon,
        title: l10n.nothingHereYet,
        message: 'Dodajte prvu stavku: ${kind.singular}.',
        compact: true,
      );
    }
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Nema stavki za „$_query”',
        compact: true,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.borderSoft),
            _ConfigItemTile(
              item: items[i],
              kind: kind,
              onEdit: () => _showEditDialog(state.type, items[i]),
              onDelete: () => _showDeleteConfirmation(state.type, items[i]),
            ),
          ],
        ],
      ),
    );
  }

  _DictionaryKind _kindFor(String type) =>
      _kinds.firstWhere((k) => k.type == type, orElse: () => _kind);

  void _showEditDialog(String type, DictionaryRefDto item) {
    final nameController = TextEditingController(text: item.name);
    final kind = _kindFor(type);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Izmena: ${kind.singular}'),
          content: SizedBox(
            width: 420,
            child: TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.enterName,
                prefixIcon: Icon(kind.icon, size: 20),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                context.read<AdminConfigBloc>().add(
                      UpdateConfigItem(type, item.id, name),
                    );
                Navigator.pop(dialogContext);
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(String type, DictionaryRefDto item) {
    final kind = _kindFor(type);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Obrisati: ${kind.singular}?'),
          content: SizedBox(
            width: 420,
            child: Text(
              '„${item.name}” se uklanja iz šifarnika. Površine koje ga koriste ostaju bez ove vrednosti.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                context.read<AdminConfigBloc>().add(
                      DeleteConfigItem(type, item.id),
                    );
                Navigator.pop(dialogContext);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.destructive,
                foregroundColor: AppColors.destructiveForeground,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }

  void _showCreateDialog(String type) {
    final nameController = TextEditingController();
    final kind = _kindFor(type);
    int? selectedCountryId;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text('Nova stavka: ${kind.singular}'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: l10n.enterName,
                        prefixIcon: Icon(kind.icon, size: 20),
                      ),
                    ),
                    if (type == 'cities') ...[
                      const SizedBox(height: 14),
                      FutureBuilder<List<DictionaryRefDto>>(
                        future: context
                            .read<AdminConfigRepository>()
                            .getItems('countries'),
                        builder: (context, snapshot) {
                          final countries = snapshot.data ?? [];
                          return DropdownButtonFormField<int>(
                            initialValue: selectedCountryId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.selectCountry,
                              prefixIcon:
                                  const Icon(Icons.flag_outlined, size: 20),
                            ),
                            items: countries
                                .map((c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(SrLabels.country(c.name)),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setDialogState(() => selectedCountryId = v);
                            },
                          );
                        },
                      ),
                    ],
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
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    if (type == 'cities' && selectedCountryId == null) return;

                    context.read<AdminConfigBloc>().add(
                          CreateConfigItem(type, name,
                              countryId: selectedCountryId),
                        );
                    Navigator.pop(dialogContext);
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ConfigItemTile extends StatefulWidget {
  final DictionaryRefDto item;
  final _DictionaryKind kind;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ConfigItemTile({
    required this.item,
    required this.kind,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<_ConfigItemTile> createState() => _ConfigItemTileState();
}

class _ConfigItemTileState extends State<_ConfigItemTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final display = widget.kind.display(item.name);
    final translated = display.isNotEmpty && display != item.name;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        color: _hover
            ? AppColors.surfaceSunken.withValues(alpha: 0.6)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translated ? display : item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLarge,
                  ),
                  if (translated)
                    Text(
                      'U bazi: ${item.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.mutedForeground),
                    ),
                ],
              ),
            ),
            Text(
              'ID ${item.id}',
              style: AppTypography.caption.copyWith(
                color: AppColors.subtle,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: widget.onEdit,
              tooltip: 'Izmeni',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.destructive),
              onPressed: widget.onDelete,
              tooltip: 'Obriši',
            ),
          ],
        ),
      ),
    );
  }
}

