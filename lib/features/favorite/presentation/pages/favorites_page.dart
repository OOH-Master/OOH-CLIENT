import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../blocs/favorite_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<FavoriteBloc>()..add(const LoadFavorites()),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.favorites),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
      ),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state is FavoritesLoading || state is FavoritesInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FavoritesError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
                  const SizedBox(height: AppSpacing.sm),
                  Text(state.message, maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: () =>
                        context.read<FavoriteBloc>().add(const LoadFavorites()),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }
          if (state is FavoritesLoaded) {
            if (state.items.isEmpty) {
              return _buildEmpty(context);
            }
            return _buildGrid(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 72, color: AppColors.mutedForeground),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context)!.noFavorites,
              style: AppTypography.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLocalizations.of(context)!.noFavoritesHint,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => context.push('/app/discover'),
              icon: const Icon(Icons.search),
              label: Text(AppLocalizations.of(context)!.exploreInventory),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, FavoritesLoaded state) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final isMed = MediaQuery.of(context).size.width >= 600;
    final crossAxisCount = isWide ? 3 : (isMed ? 2 : 1);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FavoriteBloc>().add(const LoadFavorites());
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.3,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return _FavoriteCard(
            imageUrl: _imageUrl(item.assetUrl),
            title: item.siteName ?? 'Inventar #${item.id}',
            city: item.city?.name ?? '',
            mediaOwner: item.mediaOwnerName ?? '',
            price: item.pricePerCycle,
            currency: item.currency,
            onTap: () => context.push('/app/discover/${item.id}'),
            onUnfavorite: () {
              context.read<FavoriteBloc>().add(ToggleFavorite(item.id));
            },
          );
        },
      ),
    );
  }

  String? _imageUrl(String? assetUrl) {
    if (assetUrl == null || assetUrl.isEmpty) return null;
    return ApiConfig.absoluteUrl(assetUrl);
  }
}

class _FavoriteCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String city;
  final String mediaOwner;
  final num? price;
  final String? currency;
  final VoidCallback onTap;
  final VoidCallback onUnfavorite;

  const _FavoriteCard({
    required this.imageUrl,
    required this.title,
    required this.city,
    required this.mediaOwner,
    required this.price,
    required this.currency,
    required this.onTap,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.md),
                    ),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: IconButton(
                        iconSize: 20,
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: onUnfavorite,
                        tooltip: 'Ukloni iz omiljenih',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$city${mediaOwner.isNotEmpty ? ' • $mediaOwner' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.mutedForeground),
                  ),
                  if (price != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${currency ?? ''} ${price!.toStringAsFixed(0)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.muted,
      alignment: Alignment.center,
      child: Icon(Icons.image, size: 48, color: AppColors.mutedForeground),
    );
  }
}
