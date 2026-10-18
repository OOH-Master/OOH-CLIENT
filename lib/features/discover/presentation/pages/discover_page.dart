import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../landing/presentation/widgets/app_header.dart';
import '../../data/api/inventory_api_service.dart';
import '../../domain/entities/ooh_unit.dart';
import '../blocs/discover_bloc.dart';
import '../widgets/active_filter_chips.dart';
import '../widgets/discover_card_grid.dart';
import '../widgets/discover_card_list.dart';
import '../widgets/discover_toolbar.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/inventory_map.dart';
import '../widgets/sort_dropdown.dart';
import '../widgets/unit_labels.dart';

/// Pretraga oglasnih površina: država, grad, pretraga i filteri na vrhu,
/// kartice sa cenom i dostupnošću, mapa sa grupisanim oznakama.
///
/// Ista stranica radi javno (`/discover`, sa zaglavljem sajta) i u aplikaciji
/// (`/app/discover`, bez zaglavlja jer meni daje ljuska). Na širokom ekranu
/// rezultati i mapa stoje jedno pored drugog, na telefonu je mapa preko celog
/// ekrana, a lista se izvlači preko nje.
class DiscoverPage extends StatefulWidget {
  final String? cityId;

  const DiscoverPage({super.key, this.cityId});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  /// Od ove širine sadržaja rezultati i mapa stoje jedno pored drugog.
  static const double _splitWidth = 880;

  /// Najmanja širina kartice u mreži.
  static const double _minCardWidth = 230;
  static const double _gap = 16;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Kartica nad kojom je miš; mapa ističe njenu oznaku.
  final ValueNotifier<String?> _hoveredUnitId = ValueNotifier<String?>(null);
  Timer? _searchDebounce;
  OohUnit? _selectedUnit;
  int? _autoLoadedCityId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<DiscoverBloc>();
      bloc.add(LoadCountries());
      bloc.add(LoadDictionaries());

      // Read query parameters passed from landing page
      final uri = GoRouterState.of(context).uri;
      final countryId = uri.queryParameters['countryId'];
      final cityId = uri.queryParameters['cityId'];
      final keyword = uri.queryParameters['keyword'];
      if (countryId != null || cityId != null || keyword != null) {
        bloc.add(LoadInventoryUnits(
          countryId: countryId != null ? int.tryParse(countryId) : null,
          cityId: cityId != null ? int.tryParse(cityId) : null,
          keyword: keyword,
        ));
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _hoveredUnitId.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<DiscoverBloc>().add(LoadMore());
    }
  }

  /// U aplikaciji (`/app/...`) stranica nema zaglavlje sajta.
  bool get _inApp {
    try {
      return GoRouterState.of(context).uri.path.startsWith('/app');
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inApp = _inApp;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: inApp ? null : const AppHeader(),
      body: BlocConsumer<DiscoverBloc, DiscoverState>(
        listener: _onStateChanged,
        builder: (context, state) {
          if (state is DiscoverFailure) return _buildError();
          if (state is! DiscoverLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return width >= _splitWidth
                  ? _buildWide(state, width, inApp)
                  : _buildCompact(state, width);
            },
          );
        },
      ),
    );
  }

  void _onStateChanged(BuildContext context, DiscoverState state) {
    if (state is! DiscoverLoaded) return;
    // Rezervno učitavanje kada izabrani grad ostane bez rezultata: jednom po
    // gradu i samo bez filtera, da prazan rezultat filtera ne zameni
    // nefiltriranim (i da se grad bez površina ne učitava u krug).
    final city = state.selectedCity;
    if (city != null &&
        state.units.isEmpty &&
        !state.isLoadingUnits &&
        state.activeFilterCount == 0 &&
        _autoLoadedCityId != city.id) {
      _autoLoadedCityId = city.id;
      context.read<DiscoverBloc>().add(LoadInventoryUnits(cityId: city.id));
    }
    // Kartica iznad mape ne ostaje za površinu koje više nema u rezultatima.
    final selected = _selectedUnit;
    if (selected != null &&
        !state.isLoadingUnits &&
        !state.units.any((u) => u.id == selected.id)) {
      setState(() => _selectedUnit = null);
    }
  }

  // ==================== AKCIJE ====================

  void _openDetail(OohUnit unit) {
    _hoveredUnitId.value = null;
    context.push(_inApp ? '/app/discover/${unit.id}' : '/discover/${unit.id}');
  }

  void _toggleInquiry(OohUnit unit) {
    final id = unit.intId;
    if (id != null && id > 0) {
      context.read<DiscoverBloc>().add(ToggleUnitSelection(id));
    }
  }

  void _onMarkerTap(OohUnit unit) {
    setState(() {
      _selectedUnit = _selectedUnit?.id == unit.id ? null : unit;
    });
  }

  void _setHovered(OohUnit unit, bool hovered) {
    if (hovered) {
      _hoveredUnitId.value = unit.id;
    } else if (_hoveredUnitId.value == unit.id) {
      _hoveredUnitId.value = null;
    }
  }

  /// Opens the general inquiry form, sending unauthenticated users to login.
  void _openGeneralInquiry() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      context.push('/auth/login');
      return;
    }
    context.push('/app/inquiries/create');
  }

  void _sendSelection(DiscoverLoaded state) {
    final ids = state.selectedUnitsForInquiry.join(',');
    context.push('/app/inquiries/create?unitIds=$ids');
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final state = context.read<DiscoverBloc>().state;
      if (state is DiscoverLoaded) {
        final keyword = value.trim();
        final newFilters = state.activeFilters.copyWith(
          keyword: keyword.isNotEmpty ? keyword : null,
          clearKeyword: keyword.isEmpty,
        );
        context.read<DiscoverBloc>().add(ApplyFilters(newFilters));
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  void _resetFilters() {
    _searchController.clear();
    context.read<DiscoverBloc>().add(ResetFilters());
  }

  void _onFilterRemoved(InventoryFilterParams filters) {
    if (filters.keyword == null) _searchController.clear();
    context.read<DiscoverBloc>().add(ApplyFilters(filters));
  }

  void _applyFromSheet(InventoryFilterParams filters) {
    context.read<DiscoverBloc>().add(ApplyFilters(filters));
    final keyword = filters.keyword ?? '';
    if (_searchController.text != keyword) _searchController.text = keyword;
  }

  /// Filteri: na širokom ekranu bočni panel, na telefonu list odozdo.
  void _openFilters(DiscoverLoaded state, {required bool asPanel}) {
    FilterBottomSheet sheet(bool panel) => FilterBottomSheet(
          unitTypes: state.unitTypes,
          mediaFormats: state.mediaFormats,
          venueTypes: state.venueTypes,
          currentFilters: state.activeFilters,
          units: state.units,
          asPanel: panel,
          onApply: _applyFromSheet,
          onReset: _resetFilters,
        );

    if (!asPanel) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        clipBehavior: Clip.antiAlias,
        backgroundColor: AppColors.surface,
        builder: (_) => sheet(false),
      );
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Zatvori filtere',
      barrierColor: AppColors.ink.withValues(alpha: 0.32),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, _, __) => Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 440,
          height: double.infinity,
          child: DecoratedBox(
            decoration: const BoxDecoration(boxShadow: AppShadows.raised),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(20)),
              child: sheet(true),
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, _, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }

  // ==================== ŠIROK EKRAN ====================

  Widget _buildWide(DiscoverLoaded state, double width, bool inApp) {
    final pad = width >= 1200 ? 32.0 : 24.0;
    final selected = state.selectedUnitsForInquiry;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad, inApp ? 26 : 18, pad, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (inApp) ...[
                    const PageHeader(
                      title: 'Istraži oglasne površine',
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 18),
                  ],
                  DecoratedBox(
                    decoration: AppDecorations.card(),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: DiscoverToolbar(
                        state: state,
                        searchController: _searchController,
                        onSearchChanged: _onSearchChanged,
                        onClearSearch: _clearSearch,
                        onOpenFilters: () => _openFilters(state, asPanel: true),
                      ),
                    ),
                  ),
                  if (state.activeFilterCount > 0)
                    _filterChips(state, const EdgeInsets.only(top: 12)),
                  _animatedSelection(
                    state,
                    selected.isEmpty
                        ? null
                        : Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: DiscoverSelectionBar(
                              count: selected.length,
                              units: _selectionUnits(state),
                              onClear: () => context
                                  .read<DiscoverBloc>()
                                  .add(ClearSelection()),
                              onSend: () => _sendSelection(state),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 10),
                    child: DiscoverResultsBar(
                      state: state,
                      onGeneralInquiry: _openGeneralInquiry,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildWideContent(state, pad)),
          ],
        ),
      ),
    );
  }

  Widget _buildWideContent(DiscoverLoaded state, double pad) {
    if (state.viewMode == ViewMode.mapOnly) {
      return Padding(
        padding: EdgeInsets.fromLTRB(pad, 6, pad, 24),
        child: _MapPanel(child: _buildMap(state, overlayed: false)),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = (constraints.maxWidth * 0.4).clamp(340.0, 620.0);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildResults(
                state,
                padding: EdgeInsets.fromLTRB(pad, 6, 12, 24),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: mapWidth,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 6, pad, 24),
                child: _MapPanel(child: _buildMap(state, overlayed: false)),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Rezultati kao mreža kartica ili lista redova.
  Widget _buildResults(DiscoverLoaded state, {required EdgeInsets padding}) {
    if (state.isLoadingUnits) return _buildSkeleton(padding);
    if (state.units.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - padding.vertical)
                  .clamp(0.0, double.infinity),
            ),
            child: Center(child: _buildEmptyState(state)),
          ),
        ),
      );
    }

    if (state.viewMode == ViewMode.list) {
      return ListView.separated(
        controller: _scrollController,
        padding: padding,
        itemCount: state.units.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _listRow(state, state.units[index]),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth - padding.horizontal);
        final rows = (state.units.length / columns).ceil();
        return ListView.builder(
          controller: _scrollController,
          padding: padding,
          itemCount: rows,
          itemBuilder: (context, row) => Padding(
            padding: const EdgeInsets.only(bottom: _gap),
            child: _cardRow(state, row, columns),
          ),
        );
      },
    );
  }

  int _columnsFor(double width) =>
      ((width + _gap) / (_minCardWidth + _gap)).floor().clamp(1, 4);

  /// Jedan red mreže; kartice u redu imaju istu visinu jer su istog sastava.
  Widget _cardRow(DiscoverLoaded state, int row, int columns) {
    final start = row * columns;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < columns; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          Expanded(
            child: start + i < state.units.length
                ? _gridCard(state, state.units[start + i])
                : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }

  Widget _gridCard(DiscoverLoaded state, OohUnit unit) {
    return DiscoverCardGrid(
      key: ValueKey('card-${unit.id}'),
      unit: unit,
      isSelected: _selectedUnit?.id == unit.id,
      isSelectedForInquiry:
          state.selectedUnitsForInquiry.contains(unit.intId ?? 0),
      onTap: () => _openDetail(unit),
      onAddToInquiry: () => _toggleInquiry(unit),
      onHoverChanged: (hovered) => _setHovered(unit, hovered),
    );
  }

  Widget _listRow(DiscoverLoaded state, OohUnit unit) {
    return DiscoverCardList(
      key: ValueKey('row-${unit.id}'),
      unit: unit,
      isSelected: _selectedUnit?.id == unit.id,
      isSelectedForInquiry:
          state.selectedUnitsForInquiry.contains(unit.intId ?? 0),
      onTap: () => _openDetail(unit),
      onAddToInquiry: () => _toggleInquiry(unit),
      onHoverChanged: (hovered) => _setHovered(unit, hovered),
    );
  }

  Widget _buildSkeleton(EdgeInsets padding) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth - padding.horizontal);
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: padding,
          children: [
            for (int r = 0; r < 2; r++)
              Padding(
                padding: const EdgeInsets.only(bottom: _gap),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < columns; i++) ...[
                      if (i > 0) const SizedBox(width: _gap),
                      const Expanded(child: DiscoverCardSkeleton()),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  // ==================== TELEFON I TABLET ====================

  Widget _buildCompact(DiscoverLoaded state, double width) {
    final searchInToolbar = width >= 700;
    final selected = state.selectedUnitsForInquiry;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: DiscoverToolbar(
            state: state,
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            onClearSearch: _clearSearch,
            onOpenFilters: () => _openFilters(state, asPanel: false),
            showSearch: searchInToolbar,
            compact: true,
          ),
        ),
        if (state.activeFilterCount > 0)
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: _filterChips(
                state, const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
        _animatedSelection(
          state,
          selected.isEmpty
              ? null
              : DiscoverSelectionBar(
                  count: selected.length,
                  units: _selectionUnits(state),
                  compact: true,
                  onClear: () =>
                      context.read<DiscoverBloc>().add(ClearSelection()),
                  onSend: () => _sendSelection(state),
                ),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: _buildMap(state, overlayed: true)),
              DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.15,
                maxChildSize: 0.85,
                snap: true,
                snapSizes: const [0.15, 0.4, 0.85],
                builder: (context, scrollController) => _buildSheet(
                  state,
                  scrollController,
                  width: width,
                  searchInSheet: !searchInToolbar,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSheet(
    DiscoverLoaded state,
    ScrollController controller, {
    required double width,
    required bool searchInSheet,
  }) {
    final columns = width >= 640 ? 2 : 1;
    final units = state.units;
    final rows = (units.length / columns).ceil();

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Color(0x2E111433), blurRadius: 28, offset: Offset(0, -6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: CustomScrollView(
          controller: controller,
          slivers: [
            SliverToBoxAdapter(
              child: _SheetHeader(
                state: state,
                searchField: searchInSheet
                    ? DiscoverSearchField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onClear: _clearSearch,
                      )
                    : null,
                onGeneralInquiry: _openGeneralInquiry,
              ),
            ),
            if (state.isLoadingUnits)
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverToBoxAdapter(child: DiscoverCardSkeleton()),
              )
            else if (units.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyState(state, compact: true),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: columns == 1
                          ? (state.viewMode == ViewMode.list
                              ? _listRow(state, units[index])
                              : _gridCard(state, units[index]))
                          : _cardRow(state, index, columns),
                    ),
                    childCount: columns == 1 ? units.length : rows,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== ZAJEDNIČKO ====================

  Widget _animatedSelection(DiscoverLoaded state, Widget? bar) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: bar ?? const SizedBox(width: double.infinity),
    );
  }

  /// Izabrane površine redom kojim su dodate (za sličice u traci izbora).
  List<OohUnit> _selectionUnits(DiscoverLoaded state) {
    final byId = {for (final u in state.units) u.intId: u};
    return [
      for (final id in state.selectedUnitsForInquiry)
        if (byId[id] != null) byId[id]!,
    ];
  }

  Widget _filterChips(DiscoverLoaded state, EdgeInsetsGeometry padding) {
    return ActiveFilterChips(
      filters: state.activeFilters,
      unitTypes: state.unitTypes,
      mediaFormats: state.mediaFormats,
      venueTypes: state.venueTypes,
      padding: padding,
      onFilterRemoved: _onFilterRemoved,
      onClearAll: _resetFilters,
    );
  }

  Widget _buildMap(DiscoverLoaded state, {required bool overlayed}) {
    // Determine map center and zoom based on selection
    final LatLng center;
    final double zoom;

    if (state.selectedCity != null) {
      center =
          LatLng(state.selectedCity!.latitude, state.selectedCity!.longitude);
      zoom = 12.0;
    } else if (state.selectedCountry != null && state.cities.isNotEmpty) {
      center =
          LatLng(state.cities.first.latitude, state.cities.first.longitude);
      zoom = 7.0;
    } else {
      center = const LatLng(44.0, 18.5);
      zoom = 6.0;
    }

    final selectedIds = state.selectedUnitsForInquiry;
    return InventoryMap(
      units: state.units,
      center: center,
      zoom: zoom,
      selectedUnit: _selectedUnit,
      onUnitTap: _onMarkerTap,
      onUnitDetailTap: _openDetail,
      highlightedUnitId: _hoveredUnitId,
      isInInquiry: (unit) => selectedIds.contains(unit.intId ?? 0),
      onToggleInquiry: _toggleInquiry,
      overlayed: overlayed,
    );
  }

  Widget _buildEmptyState(DiscoverLoaded state, {bool compact = false}) {
    if (state.activeFilterCount > 0) {
      return EmptyState(
        compact: compact,
        icon: Icons.filter_alt_off_outlined,
        title: 'Nema površina za izabrane filtere',
        message: 'Probajte sa manje filtera ili širim rasponom cena.',
        action: OutlinedButton.icon(
          onPressed: _resetFilters,
          icon: const Icon(Icons.restart_alt_rounded, size: 18),
          label: const Text('Poništi filtere'),
        ),
      );
    }

    final city = state.selectedCity;
    if (city != null) {
      final belgrade = state.cities
          .where((c) =>
              c.name.toLowerCase() == 'belgrade' ||
              c.name.toLowerCase() == 'beograd')
          .firstOrNull;
      final canExploreBelgrade = belgrade != null && belgrade.id != city.id;
      return EmptyState(
        compact: compact,
        icon: Icons.location_off_outlined,
        title: 'U gradu ${SrLabels.city(city.name)} još nema površina',
        message: 'Izaberite drugi grad ili pošaljite generalni upit.',
        action: canExploreBelgrade
            ? OutlinedButton.icon(
                onPressed: () =>
                    context.read<DiscoverBloc>().add(SelectCity(belgrade)),
                icon: const Icon(Icons.explore_outlined, size: 18),
                label: const Text('Istraži Beograd'),
              )
            : GeneralInquiryButton(onPressed: _openGeneralInquiry),
      );
    }

    return EmptyState(
      compact: compact,
      icon: Icons.location_city_outlined,
      title: 'Izaberite grad',
    );
  }

  Widget _buildError() {
    return EmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'Pretraga trenutno nije dostupna',
      message: 'Proverite vezu sa internetom i pokušajte ponovo.',
      action: FilledButton.icon(
        onPressed: () {
          final bloc = context.read<DiscoverBloc>();
          bloc.add(LoadCountries());
          bloc.add(LoadDictionaries());
        },
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('Pokušaj ponovo'),
      ),
    );
  }
}

/// Mapa u zaobljenom panelu na platnu stranice.
class _MapPanel extends StatelessWidget {
  final Widget child;

  const _MapPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: child,
      ),
    );
  }
}

/// Zaglavlje liste na telefonu: ručica, broj površina, generalni upit,
/// redosled i (na uskom ekranu) pretraga.
class _SheetHeader extends StatelessWidget {
  final DiscoverLoaded state;
  final Widget? searchField;
  final VoidCallback onGeneralInquiry;

  const _SheetHeader({
    required this.state,
    required this.searchField,
    required this.onGeneralInquiry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.input,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 12, 12),
          child: Row(
            children: [
              Expanded(child: DiscoverCountText(state: state, stacked: true)),
              GeneralInquiryButton(onPressed: onGeneralInquiry, iconOnly: true),
              const SizedBox(width: 8),
              SortDropdown(
                currentSort: state.sortOption,
                compact: true,
                onChanged: (sort) =>
                    context.read<DiscoverBloc>().add(ChangeSort(sort)),
              ),
            ],
          ),
        ),
        if (searchField != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: searchField!,
          ),
      ],
    );
  }
}
