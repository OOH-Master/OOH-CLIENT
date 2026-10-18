import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../discover/data/dto/dto.dart';
import '../../data/repository/agency_repository.dart';
import '../blocs/agency_bloc.dart';

class AgencyBrandsPage extends StatelessWidget {
  const AgencyBrandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AgencyBloc(context.read<AgencyRepository>())..add(LoadBrands()),
      child: const _AgencyBrandsView(),
    );
  }
}

class _AgencyBrandsView extends StatefulWidget {
  const _AgencyBrandsView();

  @override
  State<_AgencyBrandsView> createState() => _AgencyBrandsViewState();
}

class _AgencyBrandsViewState extends State<_AgencyBrandsView> {
  final _searchController = TextEditingController();
  String _query = '';

  /// Poslednja učitana lista; ostaje vidljiva dok se dodaje novi brend.
  List<DictionaryRefDto>? _last;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: wide ? null : AppBar(title: const Text('Moji brendovi')),
      floatingActionButton: wide
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addBrand),
            ),
      body: BlocConsumer<AgencyBloc, AgencyState>(
        listener: (context, state) {
          if (state is BrandCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AgencyError && _last != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.destructive,
              ),
            );
          }
        },
        buildWhen: (previous, current) => current is! BrandCreateSuccess,
        builder: (context, state) {
          if (state is BrandsLoaded) _last = state.brands;
          final brands = _last;
          final busy = state is AgencyLoading || state is AgencyInitial;

          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final side = wide ? 32.0 : 16.0;
                  final gutter =
                      math.max(side, (constraints.maxWidth - 1240) / 2);
                  final width = constraints.maxWidth - 2 * gutter;
                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<AgencyBloc>().add(LoadBrands()),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                          gutter, wide ? 0 : 16, gutter, 96),
                      children: [
                        if (wide)
                          PageHeader(
                            title: 'Moji brendovi',
                            subtitle: brands == null || brands.isEmpty
                                ? null
                                : SrFormat.count(
                                    brands.length, 'brend', 'brenda', 'brendova'),
                            padding: const EdgeInsets.only(top: 28, bottom: 22),
                            actions: [
                              FilledButton.icon(
                                onPressed: () => _showCreateDialog(context),
                                icon: const Icon(Icons.add_rounded, size: 20),
                                label: Text(l10n.addBrand),
                              ),
                            ],
                          ),
                        _buildBody(state, brands, width, l10n),
                      ],
                    ),
                  );
                },
              ),
              if (busy && brands != null)
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

  Widget _buildBody(AgencyState state, List<DictionaryRefDto>? brands,
      double width, AppLocalizations l10n) {
    if (brands == null) {
      if (state is AgencyError) {
        return SectionCard(
          child: EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Brendovi trenutno nisu dostupni',
            message: state.message,
            action: OutlinedButton.icon(
              onPressed: () => context.read<AgencyBloc>().add(LoadBrands()),
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

    if (brands.isEmpty) {
      return SectionCard(
        child: EmptyState(
          icon: Icons.storefront_outlined,
          title: 'Još nema brendova',
          message: 'Dodajte brendove klijenata.',
          action: FilledButton.icon(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(l10n.addBrand),
          ),
        ),
      );
    }

    final filtered = _query.isEmpty
        ? brands
        : brands.where((b) => b.name.toLowerCase().contains(_query)).toList();
    final columns = width >= 1000 ? 3 : (width >= 620 ? 2 : 1);
    final tileWidth = (width - (columns - 1) * 16) / columns;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: AppDecorations.card(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Pretraži brendove',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          SectionCard(
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Nema brenda „$_query”',
              compact: true,
            ),
          )
        else
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final b in filtered)
                SizedBox(width: tileWidth, child: _BrandTile(brand: b)),
            ],
          ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();

    void submit(BuildContext dialogContext) {
      final name = nameController.text.trim();
      if (name.isEmpty) return;
      context.read<AgencyBloc>().add(CreateBrand(name));
      Navigator.pop(dialogContext);
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.addBrand),
          content: SizedBox(
            width: 420,
            child: TextField(
              controller: nameController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => submit(dialogContext),
              decoration: InputDecoration(
                labelText: l10n.brandName,
                prefixIcon: const Icon(Icons.storefront_outlined, size: 20),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => submit(dialogContext),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }
}

class _BrandTile extends StatelessWidget {
  final DictionaryRefDto brand;

  const _BrandTile({required this.brand});

  @override
  Widget build(BuildContext context) {
    final name = brand.name.trim().isEmpty ? 'Brend' : brand.name;
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AppAvatar(name: name, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelLarge.copyWith(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
