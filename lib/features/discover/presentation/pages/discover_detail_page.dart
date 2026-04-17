import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/auth_guard_dialog.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../landing/presentation/widgets/app_header.dart';
import '../../domain/entities/ooh_unit.dart';
import '../blocs/discover_bloc.dart';
import '../widgets/breadcrumb.dart';
import '../widgets/image_gallery.dart';

class DiscoverDetailPage extends StatefulWidget {
  final String unitId;

  const DiscoverDetailPage({super.key, required this.unitId});

  @override
  State<DiscoverDetailPage> createState() => _DiscoverDetailPageState();
}

class _DiscoverDetailPageState extends State<DiscoverDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;

    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        OohUnit? unit;
        String? cityName;
        if (state is DiscoverLoaded) {
          unit = state.units.where((u) => u.id == widget.unitId).firstOrNull;
          cityName = state.selectedCity?.name;
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
              // Breadcrumb bar
              _buildBreadcrumbBar(unit, cityName),
              // Main content
              Expanded(
                child: isDesktop
                    ? _buildDesktopLayout(unit)
                    : _buildMobileLayout(unit),
              ),
            ],
          ),
          bottomNavigationBar: !isDesktop ? _buildMobileBottomBar(unit) : null,
        );
      },
    );
  }

  Widget _buildBreadcrumbBar(OohUnit unit, String? cityName) {
    final isLoggedIn = context.read<AuthBloc>().state is AuthAuthenticated;
    final discoverPath = isLoggedIn ? '/app/discover' : '/discover';
    final homePath = isLoggedIn ? '/app/dashboard' : '/';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => context.pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Nazad',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Breadcrumb(
              items: [
                BreadcrumbItem(
                  label: 'Pocetna',
                  onTap: () => context.go(homePath),
                ),
                BreadcrumbItem(
                  label: 'Istrazivanje',
                  onTap: () => context.go(discoverPath),
                ),
                if (cityName != null)
                  BreadcrumbItem(
                    label: cityName,
                    onTap: () => context.go(discoverPath),
                  ),
                BreadcrumbItem(label: unit.name),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(OohUnit unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: image gallery + tabs
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(unit, isDesktop: true),
                const SizedBox(height: 24),
                _buildTabSection(unit),
              ],
            ),
          ),
        ),
        // Right panel: pricing + actions
        Container(
          width: 420,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: AppColors.border)),
          ),
          child: _buildDesktopSidePanel(unit),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(OohUnit unit) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image gallery
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildImageSection(unit, isDesktop: false),
          ),
          // Title + price card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(unit),
                const SizedBox(height: 12),
                _buildPriceCard(unit),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Tabbed content
          _buildTabSection(unit),
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildImageSection(OohUnit unit, {required bool isDesktop}) {
    final images = unit.images.isNotEmpty
        ? unit.images
        : (unit.imageUrl != null ? [unit.imageUrl!] : <String>[]);

    return ImageGallery(
      images: images,
      placeholderLabel: unit.type.name.toUpperCase(),
      aspectRatio: isDesktop ? 2.2 : 16 / 9,
      showThumbnails: isDesktop,
    );
  }

  Widget _buildTabSection(OohUnit unit) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.mutedForeground,
            indicatorColor: AppColors.primary,
            labelStyle: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
            unselectedLabelStyle: AppTypography.bodySmall,
            tabs: const [
              Tab(text: 'Pregled'),
              Tab(text: 'Lokacija'),
              Tab(text: 'Specifikacije'),
              Tab(text: 'Cena'),
            ],
          ),
        ),
        // Tab content - using IndexedStack-like approach for non-scrollable tabs
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            return _buildTabContent(unit, _tabController.index);
          },
        ),
      ],
    );
  }

  Widget _buildTabContent(OohUnit unit, int index) {
    switch (index) {
      case 0:
        return _buildOverviewTab(unit);
      case 1:
        return _buildLocationTab(unit);
      case 2:
        return _buildSpecificationsTab(unit);
      case 3:
        return _buildPricingTab(unit);
      default:
        return const SizedBox.shrink();
    }
  }

  // ==================== TAB: Pregled (Overview) ====================
  Widget _buildOverviewTab(OohUnit unit) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Naziv', unit.name),
          if (unit.mediaOwnerName != null)
            _buildInfoRow('Vlasnik medija', unit.mediaOwnerName!),
          _buildInfoRow('Tip', unit.type.name.toUpperCase()),
          if (unit.specifications?['format'] != null)
            _buildInfoRow('Format', unit.specifications!['format'].toString()),
          _buildInfoRow('Okruzenje',
              unit.specifications?['environment']?.toString() ?? '-'),
          _buildInfoRow('Osvetljenje',
              unit.specifications?['illumination']?.toString() ?? '-'),
          const SizedBox(height: 16),
          Text(
            'Opis',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            unit.description ?? _generateDefaultDescription(unit),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB: Lokacija (Location) ====================
  Widget _buildLocationTab(OohUnit unit) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Adresa', unit.address),
          _buildInfoRow('Grad', unit.cityName),
          const SizedBox(height: 16),
          // Mini map
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(unit.latitude, unit.longitude),
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ooh.mobile',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(unit.latitude, unit.longitude),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Koordinate: ${unit.latitude.toStringAsFixed(5)}, ${unit.longitude.toStringAsFixed(5)}',
            style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }

  // ==================== TAB: Specifikacije ====================
  Widget _buildSpecificationsTab(OohUnit unit) {
    final specs = unit.specifications ?? {};

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (specs['dimensions'] != null)
            _buildInfoRow('Dimenzije', specs['dimensions'].toString()),
          if (specs['resolution'] != null || specs['pixelWidth'] != null)
            _buildInfoRow(
              'Rezolucija',
              specs['resolution']?.toString() ??
                  '${specs['pixelWidth'] ?? '-'}x${specs['pixelHeight'] ?? '-'}',
            ),
          if (specs['faces'] != null)
            _buildInfoRow('Broj strana', specs['faces'].toString()),
          if (specs['facingDirection'] != null)
            _buildInfoRow('Smer', specs['facingDirection'].toString()),
          if (specs['illumination'] != null)
            _buildInfoRow('Osvetljenje', specs['illumination'].toString()),
          if (specs['format'] != null)
            _buildInfoRow('Format', specs['format'].toString()),
          if (specs['venueType'] != null)
            _buildInfoRow('Tip lokacije', specs['venueType'].toString()),
          if (specs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 48, color: AppColors.mutedForeground),
                    const SizedBox(height: 8),
                    Text(
                      'Specifikacije nisu dostupne',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== TAB: Cena (Pricing) ====================
  Widget _buildPricingTab(OohUnit unit) {
    final formatter = NumberFormat('#,###', 'en_US');
    final specs = unit.specifications ?? {};

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceCard(unit),
          const SizedBox(height: 16),
          if (specs['productionCost'] != null)
            _buildInfoRow(
              'Troskovi produkcije',
              '${unit.currency} ${formatter.format((specs['productionCost'] as num).round())}',
            ),
          if (specs['cpm'] != null)
            _buildInfoRow(
              'CPM',
              '${unit.currency} ${(specs['cpm'] as num).toStringAsFixed(2)}',
            ),
          if (specs['impressions'] != null)
            _buildInfoRow(
              'Impresije',
              formatter.format(specs['impressions'] as int),
            ),
        ],
      ),
    );
  }

  // ==================== SHARED WIDGETS ====================

  Widget _buildTitleSection(OohUnit unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            unit.type.name.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          unit.name,
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: AppColors.mutedForeground),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${unit.address}, ${unit.cityName}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
        if (unit.mediaOwnerName != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.business, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                unit.mediaOwnerName!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        // Availability badge
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: unit.isAvailable ? AppColors.success : AppColors.destructive,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              unit.isAvailable ? 'Dostupno' : 'Zauzeto',
              style: AppTypography.bodySmall.copyWith(
                color: unit.isAvailable ? AppColors.success : AppColors.destructive,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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

  Widget _buildDesktopSidePanel(OohUnit unit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(unit),
          const SizedBox(height: 20),
          _buildPriceCard(unit),
          const SizedBox(height: 20),
          // Updated date
          _buildUpdatedDate(unit),
          const Divider(height: 40),
          // Actions
          _buildDesktopActions(unit),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
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
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _handleStartInquiry,
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Posalji upit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _handleAddToInquiry(unit),
            icon: Icon(Icons.add_shopping_cart, size: 18, color: AppColors.primary),
            label: Text('Dodaj u upit', style: TextStyle(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // General inquiry CTA
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.muted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.support_agent, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Treba vam pomoc?',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Opisite vasu kampanju i nasi eksperti ce vam predloziti najbolje lokacije.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _handleGeneralInquiry,
                  icon: Icon(Icons.mail_outline, size: 16, color: AppColors.primary),
                  label: Text(
                    'Posalji generalni upit',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _handleShare,
            icon: Icon(Icons.share_outlined, size: 16, color: AppColors.foreground),
            label: Text(
              l10n.share,
              style: AppTypography.bodySmall.copyWith(color: AppColors.foreground),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: AppColors.border),
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
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleAddToInquiry(unit),
                icon: Icon(Icons.add_shopping_cart, size: 16, color: AppColors.primary),
                label: Text(
                  'Dodaj u upit',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _handleStartInquiry,
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Posalji upit'),
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

  String _generateDefaultDescription(OohUnit unit) {
    return '${unit.name} je ${unit.type.name} oglasni prostor koji se nalazi '
        'na adresi ${unit.address}. '
        'Lociran u ${unit.cityName}, pruza odlicnu vidljivost '
        'sa glavnih saobracajnih ruta i pesackih zona.';
  }

  void _handleShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.comingSoon)),
    );
  }

  void _handleGeneralInquiry() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      AuthGuardDialog.show(context);
      return;
    }
    context.push('/app/inquiries/create');
  }

  void _handleStartInquiry() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      AuthGuardDialog.show(context);
      return;
    }
    context.push('/app/inquiries/create?unitIds=${widget.unitId}');
  }

  void _handleAddToInquiry(OohUnit unit) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      AuthGuardDialog.show(context);
      return;
    }
    final unitIdInt = int.tryParse(unit.id);
    if (unitIdInt != null) {
      context.read<DiscoverBloc>().add(ToggleUnitSelection(unitIdInt));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${unit.name} dodat u upit'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
