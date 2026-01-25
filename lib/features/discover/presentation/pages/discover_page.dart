import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/spacing.dart';
import '../../domain/entities/ooh_filters.dart';
import '../../domain/entities/ooh_unit.dart';
import '../blocs/discover_bloc.dart';
import '../widgets/ooh_card.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  void initState() {
    super.initState();
    // Trigger initial load if not loaded
    final state = context.read<DiscoverBloc>().state;
    if (state is DiscoverInitial) {
      context.read<DiscoverBloc>().add(DiscoverStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          _buildFilters(context, l10n),
          Expanded(
            child: BlocBuilder<DiscoverBloc, DiscoverState>(
              builder: (context, state) {
                if (state is DiscoverLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DiscoverFailure) {
                  return Center(child: Text(state.message));
                } else if (state is DiscoverLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<DiscoverBloc>().add(RefreshRequested());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(Spacing.md),
                      itemCount: state.units.length,
                      itemBuilder: (context, index) {
                        return OohCard(unit: state.units[index]);
                      },
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

  Widget _buildFilters(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        child: Row(
          children: [
            _FilterChip(
              label: l10n.filterType,
              onSelected: () => _showTypeFilterDialog(context),
            ),
            const SizedBox(width: Spacing.sm),
            _FilterChip(
              label: l10n.filterArea,
              onSelected: () {}, // Implement area filter dialog
            ),
            const SizedBox(width: Spacing.sm),
            _FilterChip(
              label: l10n.filterPrice,
              onSelected: () {}, // Implement price filter dialog
            ),
          ],
        ),
      ),
    );
  }

  void _showTypeFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Select Type'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                context.read<DiscoverBloc>().add(
                  const FiltersChanged(OohFilters(type: null)),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('All'),
            ),
            ...OohType.values.map(
              (type) => SimpleDialogOption(
                onPressed: () {
                  context.read<DiscoverBloc>().add(
                    FiltersChanged(OohFilters(type: type)),
                  );
                  Navigator.pop(dialogContext);
                },
                child: Text(type.name.toUpperCase()),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onSelected;

  const _FilterChip({required this.label, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 18),
        ],
      ),
      onPressed: onSelected,
    );
  }
}
