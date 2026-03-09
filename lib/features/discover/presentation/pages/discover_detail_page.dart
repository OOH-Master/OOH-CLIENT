import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/auth_guard_dialog.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../landing/presentation/widgets/app_header.dart';
import '../../domain/entities/ooh_unit.dart';
import '../blocs/discover_bloc.dart';

class DiscoverDetailPage extends StatefulWidget {
  final String unitId;

  const DiscoverDetailPage({super.key, required this.unitId});

  @override
  State<DiscoverDetailPage> createState() => _DiscoverDetailPageState();
}

class _DiscoverDetailPageState extends State<DiscoverDetailPage> {
  bool _isDescriptionExpanded = false;
  int _currentImageIndex = 0;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;

    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        OohUnit? unit;
        if (state is DiscoverLoaded) {
          unit = state.units.where((u) => u.id == widget.unitId).firstOrNull;
        }

        if (unit == null) {
          return Scaffold(
            appBar: const AppHeader(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const AppHeader(),
          body: Column(
            children: [
              // Back navigation bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        unit.name,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: isDesktop ? _buildDesktopLayout(unit) : _buildMobileLayout(unit),
              ),
            ],
          ),
          bottomNavigationBar: !isDesktop ? _buildMobileBottomBar(unit) : null,
        );
      },
    );
  }

  Widget _buildDesktopLayout(OohUnit unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(unit, isDesktop: true),
                const SizedBox(height: 32),
                _buildProposalSection(unit),
                const SizedBox(height: 48),
                _buildFooter(),
              ],
            ),
          ),
        ),
        Container(
          width: 420,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: AppColors.border)),
          ),
          child: _buildDetailsPanel(unit),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(OohUnit unit) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(unit, isDesktop: false),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(unit),
                const SizedBox(height: 16),
                _buildDescriptionSection(unit),
                const SizedBox(height: 16),
                _buildUpdatedDate(unit),
                const SizedBox(height: 24),
                _buildProposalSection(unit),
                const SizedBox(height: 32),
                _buildFooter(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(OohUnit unit, {required bool isDesktop}) {
    final images = unit.images.isNotEmpty ? unit.images : [unit.imageUrl ?? ''];
    final hasValidImages = images.any((img) => img.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: isDesktop ? 2.2 : 16 / 9,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(isDesktop ? 12 : 0),
                child: Container(
                  color: AppColors.muted,
                  child: hasValidImages && images[_currentImageIndex].isNotEmpty
                      ? Image.network(
                          images[_currentImageIndex],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(unit),
                        )
                      : _buildImagePlaceholder(unit),
                ),
              ),
              if (unit.isAvailable)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.foreground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'NEW',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (isDesktop)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: _buildViewLargerButton(),
                ),
              if (images.length > 1)
                Positioned(
                  bottom: 16,
                  right: isDesktop ? 180 : 16,
                  child: _buildImageDots(images.length),
                ),
            ],
          ),
        ),
        if (isDesktop && images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _currentImageIndex;
                return GestureDetector(
                  onTap: () => setState(() => _currentImageIndex = index),
                  child: Container(
                    width: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: images[index].isNotEmpty
                          ? Image.network(images[index], fit: BoxFit.cover)
                          : Container(color: AppColors.muted),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildViewLargerButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: _openImageViewer,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 16, color: AppColors.foreground),
              const SizedBox(width: 6),
              Text(
                l10n.viewLargerPhoto,
                style: AppTypography.bodySmall.copyWith(color: AppColors.foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageDots(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isSelected = index == _currentImageIndex;
        return GestureDetector(
          onTap: () => setState(() => _currentImageIndex = index),
          child: Container(
            width: isSelected ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImagePlaceholder(OohUnit unit) {
    return Container(
      color: AppColors.muted,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 64, color: AppColors.mutedForeground),
          const SizedBox(height: 8),
          Text(
            unit.type.name.toUpperCase(),
            style: AppTypography.labelMedium.copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel(OohUnit unit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(unit),
          const SizedBox(height: 16),
          _buildLocationInfo(unit),
          const SizedBox(height: 20),
          _buildPriceCard(unit),
          const SizedBox(height: 20),
          _buildSpecificationsSection(unit),
          const SizedBox(height: 20),
          _buildDescriptionSection(unit),
          const SizedBox(height: 20),
          _buildUpdatedDate(unit),
          const Divider(height: 40),
          _buildDesktopActions(unit),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(OohUnit unit) {
    return Row(
      children: [
        Icon(Icons.location_on, size: 16, color: AppColors.mutedForeground),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            unit.address.isNotEmpty ? unit.address : unit.cityName,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(OohUnit unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.advertisingPeriod,
            style: AppTypography.labelSmall.copyWith(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 4),
          Text(
            _getCycleDisplayLocalized(unit.cycleType),
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            unit.priceDisplay,
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsSection(OohUnit unit) {
    final specs = unit.specifications ?? {};
    if (specs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.muted.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (specs['dimensions'] != null) _buildSpecRow('Dimensions', specs['dimensions'].toString()),
              if (specs['resolution'] != null) _buildSpecRow('Resolution', specs['resolution'].toString()),
              if (specs['illumination'] != null) _buildSpecRow('Illumination', specs['illumination'].toString()),
              if (specs['format'] != null) _buildSpecRow('Format', specs['format'].toString()),
              if (specs['venueType'] != null) _buildSpecRow('Venue', specs['venueType'].toString()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(OohUnit unit) {
    return Text(
      unit.name,
      style: AppTypography.h3.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.foreground,
      ),
    );
  }

  Widget _buildDescriptionSection(OohUnit unit) {
    final description = unit.description ?? _generateDefaultDescription(unit);
    final isLong = description.length > 200;
    final displayText = _isDescriptionExpanded || !isLong
        ? description
        : '${description.substring(0, 200)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mutedForeground,
            height: 1.6,
          ),
        ),
        if (isLong) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
            child: Row(
              children: [
                Text(
                  _isDescriptionExpanded ? l10n.seeLess : l10n.seeMore,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
                ),
                Icon(
                  _isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _generateDefaultDescription(OohUnit unit) {
    return 'The ${unit.name} is a ${unit.type.name} advertising space located '
        'near a key downtown intersection on ${unit.address}. '
        'Located at ${unit.cityName}, it naturally commands visibility from '
        'major traffic routes and pedestrian areas.';
  }

  Widget _buildUpdatedDate(OohUnit unit) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final date = unit.availableFrom ?? DateTime.now();

    return Row(
      children: [
        Text(
          l10n.updated,
          style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
        ),
        const SizedBox(width: 8),
        Text(
          dateFormat.format(date),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopActions(OohUnit unit) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: _handleShare,
            icon: Icon(Icons.share_outlined, color: AppColors.foreground),
            tooltip: l10n.share,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _handleStartInquiry,
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(l10n.startMediaInquiry),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBottomBar(OohUnit unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: _handleShare,
                icon: Icon(Icons.share_outlined, color: AppColors.foreground),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _handleStartInquiry,
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(l10n.startMediaInquiry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProposalSection(OohUnit unit) {
    final formatter = NumberFormat('#,###', 'en_US');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.addToProposal,
                style: AppTypography.h5.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Text('📋', style: TextStyle(fontSize: 20)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🎨', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    l10n.howToUseMediaProducts,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.howToUseMediaProductsDescription,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.individual,
                style: AppTypography.labelSmall.copyWith(color: AppColors.mutedForeground),
              ),
              const SizedBox(height: 8),
              Text(
                unit.name,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.advertisingPeriod,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
                  ),
                  Text(
                    _getCycleDisplayLocalized(unit.cycleType),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Text(
                '${formatter.format(unit.price.round())} ${unit.currency}',
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _handleAddProposal,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(l10n.addProposal),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getCycleDisplayLocalized(CycleType cycle) {
    switch (cycle) {
      case CycleType.oneDay:
        return l10n.day;
      case CycleType.oneWeek:
        return l10n.week;
      case CycleType.twoWeek:
        return l10n.twoWeeks;
      case CycleType.fourWeek:
        return l10n.fourWeeks;
      case CycleType.oneMonth:
        return '1 ${l10n.month}';
    }
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.apartment, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.appName,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© 2026 AutoHome. All rights reserved.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }

  void _handleShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.comingSoon)),
    );
  }

  void _handleStartInquiry() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      AuthGuardDialog.show(context);
      return;
    }
    context.push('/app/inquiries/create?unitIds=${widget.unitId}');
  }

  void _handleAddProposal() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      AuthGuardDialog.show(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.comingSoon)),
    );
  }

  void _openImageViewer() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.comingSoon)),
    );
  }
}
