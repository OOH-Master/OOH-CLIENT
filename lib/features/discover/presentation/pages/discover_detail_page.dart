import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/auth_guard_dialog.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../landing/presentation/widgets/app_header.dart';
import '../../data/repository/discover_repository.dart';
import '../../domain/entities/ooh_unit.dart';
import '../blocs/discover_bloc.dart';
import '../widgets/breadcrumb.dart';
import '../widgets/image_gallery.dart';
import '../widgets/unit_card_parts.dart';
import '../widgets/unit_detail_sections.dart';
import '../widgets/unit_labels.dart';

/// Detalj oglasne površine: velika fotografija, ispod nje kartice Pregled,
/// Lokacija, Specifikacije i Cena; desno cena za period zakupa, dostupnost,
/// "Dodaj u upit", "Pošalji upit" i generalni upit. Na telefonu je sve u
/// jednoj koloni, istim redom.
class DiscoverDetailPage extends StatefulWidget {
  final String unitId;

  const DiscoverDetailPage({super.key, required this.unitId});

  @override
  State<DiscoverDetailPage> createState() => _DiscoverDetailPageState();
}

class _DiscoverDetailPageState extends State<DiscoverDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Površina učitana posebno, kada je nema u rezultatima pretrage
  /// (npr. otvorena iz omiljenih ili preko linka).
  OohUnit? _fetched;
  bool _fetching = false;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureUnit());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _inApp {
    try {
      return GoRouterState.of(context).uri.path.startsWith('/app');
    } catch (_) {
      return false;
    }
  }

  OohUnit? _fromBloc(DiscoverState state) => state is DiscoverLoaded
      ? state.units.where((u) => u.id == widget.unitId).firstOrNull
      : null;

  Future<void> _ensureUnit() async {
    if (!mounted || _fetching || _fetched != null) return;
    if (_fromBloc(context.read<DiscoverBloc>().state) != null) return;
    final id = int.tryParse(widget.unitId);
    if (id == null) {
      setState(() => _notFound = true);
      return;
    }
    _fetching = true;
    final repository = context.read<DiscoverRepository>();
    final result = await repository.getUnitById(id);
    if (!mounted) return;
    setState(() {
      _fetching = false;
      switch (result) {
        case Success(data: final unit):
          _fetched = unit;
        case Error():
          _notFound = true;
      }
    });
  }

  String get _discoverPath =>
      context.read<AuthBloc>().state is AuthAuthenticated
          ? '/app/discover'
          : '/discover';

  @override
  Widget build(BuildContext context) {
    final inApp = _inApp;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: inApp ? null : const AppHeader(),
      body: BlocBuilder<DiscoverBloc, DiscoverState>(
        builder: (context, state) {
          final unit = _fromBloc(state) ?? _fetched;
          if (unit == null) {
            return _notFound
                ? _buildNotFound()
                : const Center(child: CircularProgressIndicator());
          }
          final selected = state is DiscoverLoaded
              ? state.selectedUnitsForInquiry
              : const <int>[];
          final inBasket = selected.contains(unit.intId ?? -1);
          return LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth >= 900
                ? _buildWide(unit, inBasket, constraints.maxWidth)
                : _buildSingleColumn(unit, inBasket, constraints.maxWidth),
          );
        },
      ),
    );
  }

  // ==================== RASPORED ====================

  Widget _buildWide(OohUnit unit, bool inBasket, double width) {
    final pad = width >= 1200 ? 32.0 : 24.0;
    final sideWidth = (width * 0.3).clamp(330.0, 400.0);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1240 + pad * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 22, pad, 14),
              child: _buildTopBar(unit),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(pad, 4, 12, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildGallery(unit),
                          const SizedBox(height: 20),
                          _buildTabs(unit, wide: true),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: sideWidth + 12 + pad,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(12, 4, pad, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPriceCard(unit, inBasket),
                            const SizedBox(height: 16),
                            GeneralInquiryBox(onPressed: _handleGeneralInquiry),
                          ],
                        ),
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

  Widget _buildSingleColumn(OohUnit unit, bool inBasket, double width) {
    final pad = width >= 600 ? 24.0 : 16.0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 14, pad, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(unit),
              const SizedBox(height: 14),
              _buildGallery(unit),
              const SizedBox(height: 16),
              // u jednoj koloni cena i dugmad idu odmah posle fotografije, kao
              // desna kolona na širokom ekranu
              _buildPriceCard(unit, inBasket),
              const SizedBox(height: 16),
              _buildTabs(unit, wide: false),
              const SizedBox(height: 16),
              GeneralInquiryBox(onPressed: _handleGeneralInquiry),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== DELOVI ====================

  Widget _buildTopBar(OohUnit unit) {
    return Row(
      children: [
        _SquareIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Nazad',
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(_discoverPath);
            }
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Breadcrumb(
            items: [
              BreadcrumbItem(
                label: 'Istraži',
                onTap: () => context.go(_discoverPath),
              ),
              if (unit.cityLabel.isNotEmpty)
                BreadcrumbItem(
                  label: unit.cityLabel,
                  onTap: () => context.go(_discoverPath),
                ),
              BreadcrumbItem(label: unit.title),
            ],
          ),
        ),
        const SizedBox(width: 8),
        UnitFavoriteButton(unit: unit, onSurface: true, size: 38),
        const SizedBox(width: 8),
        _SquareIconButton(
          icon: Icons.ios_share_rounded,
          tooltip: 'Podeli',
          onTap: () => _handleShare(unit),
        ),
      ],
    );
  }

  Widget _buildGallery(OohUnit unit) {
    final images = unit.images.isNotEmpty
        ? unit.images
        : (unit.imageUrl != null ? [unit.imageUrl!] : <String>[]);
    return ImageGallery(
      images: images,
      aspectRatio: 16 / 9,
      radius: AppRadius.card,
      digital: unit.isDigitalUnit,
      showThumbnails: true,
      topLeft: UnitTypeBadge(unit: unit),
    );
  }

  Widget _buildTabs(OohUnit unit, {required bool wide}) {
    return DecoratedBox(
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: wide ? 12 : 4),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 14),
              tabs: const [
                Tab(text: 'Pregled'),
                Tab(text: 'Lokacija'),
                Tab(text: 'Specifikacije'),
                Tab(text: 'Cena'),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              final index = _tabController.index;
              final Widget content = switch (index) {
                0 => UnitOverviewTab(unit: unit),
                1 => UnitLocationTab(unit: unit, wide: wide),
                2 => UnitSpecsTab(unit: unit, wide: wide),
                _ => UnitPricingTab(unit: unit),
              };
              return Padding(
                padding: EdgeInsets.all(wide ? 24 : 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topLeft,
                    children: [...previous, if (current != null) current],
                  ),
                  child: KeyedSubtree(key: ValueKey(index), child: content),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(OohUnit unit, bool inBasket) {
    return UnitPriceCard(
      unit: unit,
      inBasket: inBasket,
      onToggleInquiry: () => _handleToggleInquiry(unit, inBasket),
      onSendInquiry: _handleStartInquiry,
    );
  }

  Widget _buildNotFound() {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'Površina nije pronađena',
      message: 'Možda je uklonjena iz ponude.',
      action: FilledButton.icon(
        onPressed: () => context.go(_discoverPath),
        icon: const Icon(Icons.travel_explore_rounded, size: 18),
        label: const Text('Nazad na pretragu'),
      ),
    );
  }

  // ==================== AKCIJE ====================

  bool _requireAuth() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      AuthGuardDialog.show(context);
      return false;
    }
    return true;
  }

  Future<void> _handleShare(OohUnit unit) async {
    final text = kIsWeb
        ? Uri.base.toString()
        : '${unit.title}, ${unit.cityAndCountry}, ${unit.priceDisplay}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(kIsWeb
            ? 'Link ka površini je kopiran'
            : 'Podaci o površini su kopirani'),
        duration: const Duration(seconds: 2),
      ));
  }

  void _handleGeneralInquiry() {
    if (!_requireAuth()) return;
    context.push('/app/inquiries/create');
  }

  void _handleStartInquiry() {
    if (!_requireAuth()) return;
    context.push('/app/inquiries/create?unitIds=${widget.unitId}');
  }

  void _handleToggleInquiry(OohUnit unit, bool inBasket) {
    if (!_requireAuth()) return;
    final id = unit.intId;
    if (id == null) return;
    final bloc = context.read<DiscoverBloc>();
    // Bez učitane pretrage nema izbora više površina; upit ide za ovu površinu.
    if (bloc.state is! DiscoverLoaded) {
      _handleStartInquiry();
      return;
    }
    bloc.add(ToggleUnitSelection(id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(inBasket
            ? '${unit.title}: uklonjeno iz upita'
            : '${unit.title}: dodato u upit'),
        duration: const Duration(seconds: 2),
      ));
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SquareIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 19, color: AppColors.text2),
          ),
        ),
      ),
    );
  }
}
