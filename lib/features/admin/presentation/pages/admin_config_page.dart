import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
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

class _AdminConfigView extends StatefulWidget {
  const _AdminConfigView();

  @override
  State<_AdminConfigView> createState() => _AdminConfigViewState();
}

class _AdminConfigViewState extends State<_AdminConfigView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['countries', 'cities', 'unitTypes', 'mediaFormats', 'venueTypes'];

  AppLocalizations get l10n => AppLocalizations.of(context)!;

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
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      context.read<AdminConfigBloc>().add(LoadConfigTab(_tabs[_tabController.index]));
    }
  }

  String _tabLabel(String type) {
    switch (type) {
      case 'countries':
        return l10n.countries;
      case 'cities':
        return l10n.cities;
      case 'unitTypes':
        return l10n.unitTypes;
      case 'mediaFormats':
        return l10n.mediaFormats;
      case 'venueTypes':
        return l10n.venueTypes;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.configManagement),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.mutedForeground,
          indicatorColor: AppColors.primary,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: _tabLabel(t))).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(_tabs[_tabController.index]),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<AdminConfigBloc, AdminConfigState>(
        listener: (context, state) {
          if (state is AdminConfigCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.configCreated)),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminConfigLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminConfigError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message, style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context
                        .read<AdminConfigBloc>()
                        .add(LoadConfigTab(_tabs[_tabController.index])),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state is AdminConfigLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open,
                        size: 64, color: AppColors.mutedForeground),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.nothingHereYet,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _ConfigItemTile(item: item);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCreateDialog(String type) {
    final nameController = TextEditingController();
    int? selectedCountryId;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(l10n.addNew),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.enterName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (type == 'cities') ...[
                    const SizedBox(height: AppSpacing.md),
                    FutureBuilder<List<DictionaryRefDto>>(
                      future: context
                          .read<AdminConfigRepository>()
                          .getItems('countries'),
                      builder: (context, snapshot) {
                        final countries = snapshot.data ?? [];
                        return DropdownButtonFormField<int>(
                          value: selectedCountryId,
                          decoration: InputDecoration(
                            labelText: l10n.selectCountry,
                            border: const OutlineInputBorder(),
                          ),
                          items: countries
                              .map((c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                  ),
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

class _ConfigItemTile extends StatelessWidget {
  final DictionaryRefDto item;
  const _ConfigItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.label_outline, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              item.name,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.foreground,
              ),
            ),
          ),
          Text(
            '#${item.id}',
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
