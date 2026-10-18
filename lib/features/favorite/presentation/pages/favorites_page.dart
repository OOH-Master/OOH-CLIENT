import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../discover/data/mapper/discover_mapper.dart';
import '../../../discover/presentation/widgets/discover_card_grid.dart';
import '../blocs/favorite_bloc.dart';

/// Omiljene površine: iste kartice kao u pretrazi, sa srcem za uklanjanje.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    context.read<FavoriteBloc>().add(const LoadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: wide ? null : AppBar(title: const Text('Omiljene površine')),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          final count = state is FavoritesLoaded ? state.items.length : null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wide)
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1304),
                    child: PageHeader(
                      title: 'Omiljene površine',
                      subtitle: count == null || count == 0
                          ? null
                          : SrFormat.count(count, 'sačuvana površina',
                              'sačuvane površine', 'sačuvanih površina'),
                    ),
                  ),
                ),
              Expanded(child: _buildBody(context, state, wide)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, FavoriteState state, bool wide) {
    if (state is FavoritesLoading || state is FavoritesInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is FavoritesError) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Omiljene površine nisu učitane',
        message: 'Proverite vezu sa internetom i pokušajte ponovo.',
        action: OutlinedButton.icon(
          onPressed: () =>
              context.read<FavoriteBloc>().add(const LoadFavorites()),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Pokušaj ponovo'),
        ),
      );
    }
    if (state is FavoritesLoaded) {
      if (state.items.isEmpty) return _buildEmpty(context);
      return _buildGrid(context, state, wide);
    }
    return const SizedBox.shrink();
  }

  Widget _buildEmpty(BuildContext context) {
    return EmptyState(
      icon: Icons.favorite_border_rounded,
      title: 'Nemate sačuvanih površina',
      message: 'Označite površinu srcem u pretrazi ili na detalju.',
      action: FilledButton.icon(
        onPressed: () => context.push('/app/discover'),
        icon: const Icon(Icons.travel_explore_rounded, size: 18),
        label: const Text('Istraži površine'),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, FavoritesLoaded state, bool wide) {
    final units = state.items.map(DiscoverMapper.unitFromDto).toList();
    final pad = wide ? 32.0 : 16.0;
    const gap = 16.0;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FavoriteBloc>().add(const LoadFavorites());
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1240 + pad * 2),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final inner = constraints.maxWidth - pad * 2;
              final columns = ((inner + gap) / (260 + gap)).floor().clamp(1, 4);
              final rows = (units.length / columns).ceil();
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(pad, wide ? 4 : 16, pad, 32),
                itemCount: rows,
                itemBuilder: (context, row) {
                  final start = row * columns;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: gap),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < columns; i++) ...[
                          if (i > 0) const SizedBox(width: gap),
                          Expanded(
                            child: start + i < units.length
                                ? DiscoverCardGrid(
                                    key: ValueKey('fav-${units[start + i].id}'),
                                    unit: units[start + i],
                                    onTap: () => context.push(
                                        '/app/discover/${units[start + i].id}'),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
