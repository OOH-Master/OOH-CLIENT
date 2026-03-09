import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../landing/presentation/widgets/app_header.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/ooh_unit.dart';
import '../blocs/discover_bloc.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/inventory_map.dart';

class DiscoverPage extends StatefulWidget {
  final String? cityId;

  const DiscoverPage({super.key, this.cityId});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  OohUnit? _selectedUnit;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<DiscoverBloc>();
      bloc.add(LoadCountries());
      bloc.add(LoadDictionaries());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: const AppHeader(),
      body: Column(
        children: [
          // Secondary toolbar with city dropdown and filters
          _buildSecondaryToolbar(isDesktop),
          // Main content
          Expanded(
            child: BlocConsumer<DiscoverBloc, DiscoverState>(
              listener: (context, state) {
                if (state is DiscoverLoaded &&
                    state.selectedCity != null &&
                    state.units.isEmpty &&
                    !state.isLoadingUnits) {
                  context.read<DiscoverBloc>().add(LoadInventoryUnits(cityId: state.selectedCity!.id));
                }
              },
              builder: (context, state) {
                if (state is DiscoverInitial || (state is DiscoverLoading && state is! DiscoverLoaded)) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DiscoverFailure) {
                  return _buildErrorState(state.message);
                }

                if (state is DiscoverLoaded) {
                  if (isDesktop) {
                    return _buildDesktopLayout(state);
                  } else {
                    return _buildMobileLayout(state);
                  }
                }

                return Center(
                  child: Text(
                    l10n.selectCityToViewInventory,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryToolbar(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: BlocBuilder<DiscoverBloc, DiscoverState>(
        builder: (context, state) {
          if (state is DiscoverLoaded) {
            return Row(
              children: [
                Expanded(
                  child: _buildCountryDropdown(state),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCityDropdown(state, isDesktop),
                ),
                const SizedBox(width: 12),
                if (isDesktop) ...[
                  Expanded(child: _buildSearchField()),
                  const SizedBox(width: 12),
                  _buildFilterButton(state),
                ],
                if (!isDesktop) ...[
                  _buildFilterButton(state),
                ],
              ],
            );
          }
          return const SizedBox(height: 48);
        },
      ),
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout(DiscoverLoaded state) {
    return Row(
      children: [
        // Left side - 3 column grid
        SizedBox(
          width: 720,
          child: _buildInventoryGrid(state),
        ),
        // Right side - Map
        Expanded(
          child: _buildMapSection(state),
        ),
      ],
    );
  }

  Widget _buildInventoryGrid(DiscoverLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.results(state.units.length),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
                if (state.selectedCity != null)
                  Text(
                    state.selectedCity!.name,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          // Grid
          Expanded(
            child: state.isLoadingUnits
                ? const Center(child: CircularProgressIndicator())
                : state.units.isEmpty
                    ? _buildEmptyState(state)
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: state.units.length,
                        itemBuilder: (context, index) {
                          return _buildInventoryCard(state.units[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout(DiscoverLoaded state) {
    return Stack(
      children: [
        // Map as background
        _buildMapSection(state),
        // Draggable bottom sheet with inventory list
        DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.15,
          maxChildSize: 0.85,
          snap: true,
          snapSizes: const [0.15, 0.4, 0.85],
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  // Handle bar and header (non-scrollable pinned)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Handle bar - makes dragging easier
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.border,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.results(state.units.length),
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.foreground,
                                ),
                              ),
                              if (state.selectedCity != null)
                                Text(
                                  state.selectedCity!.name,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: AppColors.border),
                      ],
                    ),
                  ),
                  // Content
                  if (state.isLoadingUnits)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.units.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(state),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(12),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final unit = state.units[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildMobileInventoryCard(unit),
                            );
                          },
                          childCount: state.units.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ==================== MOBILE INVENTORY CARD ====================
  Widget _buildMobileInventoryCard(OohUnit unit) {
    final isSelected = _selectedUnit?.id == unit.id;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedUnit = unit);
        context.push('/discover/${unit.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image on left
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
              child: SizedBox(
                width: 120,
                height: 100,
                child: unit.imageUrl != null
                    ? Image.network(
                        unit.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
            // Info on right
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      unit.name,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unit.address,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          unit.priceDisplay,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: unit.isAvailable ? AppColors.success : AppColors.warning,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            unit.isAvailable ? l10n.available : l10n.booked,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== INVENTORY CARD ====================
  Widget _buildInventoryCard(OohUnit unit) {
    final isSelected = _selectedUnit?.id == unit.id;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedUnit = unit);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppColors.muted,
                      child: unit.imageUrl != null
                          ? Image.network(
                              unit.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                    // Status badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: unit.isAvailable ? AppColors.success : AppColors.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          unit.isAvailable ? l10n.available : l10n.booked,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: AppColors.mutedForeground),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            unit.cityName,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            unit.priceDisplay,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _navigateToDetail(unit),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.view,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SHARED COMPONENTS ====================
  Widget _buildCountryDropdown(DiscoverLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Country?>(
          value: state.selectedCountry,
          dropdownColor: Colors.white,
          hint: Text(
            l10n.selectCountry,
            style: TextStyle(fontSize: 14, color: AppColors.mutedForeground),
          ),
          isDense: true,
          isExpanded: true,
          items: [
            DropdownMenuItem<Country?>(
              value: null,
              child: Text(
                l10n.allCountries,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ...state.countries.map((country) {
              return DropdownMenuItem<Country?>(
                value: country,
                child: Text(
                  country.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: AppColors.foreground),
                ),
              );
            }),
          ],
          onChanged: (country) {
            context.read<DiscoverBloc>().add(SelectCountry(country));
          },
        ),
      ),
    );
  }

  Widget _buildCityDropdown(DiscoverLoaded state, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<City?>(
          value: state.selectedCity,
          dropdownColor: Colors.white,
          hint: Text(
            l10n.selectCity,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
          ),
          isDense: true,
          isExpanded: true,
          items: [
            DropdownMenuItem<City?>(
              value: null,
              child: Text(
                l10n.allCities,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ...state.cities.map((city) {
              return DropdownMenuItem<City?>(
                value: city,
                child: Text(
                  '${city.name}, ${city.country}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: AppColors.foreground),
                ),
              );
            }),
          ],
          onChanged: (city) {
            context.read<DiscoverBloc>().add(SelectCity(city));
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: TextStyle(fontSize: 14, color: AppColors.foreground),
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: l10n.searchPlaceholder,
        hintStyle: TextStyle(fontSize: 14, color: AppColors.mutedForeground),
        prefixIcon: Icon(Icons.search, color: AppColors.mutedForeground, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, size: 18, color: AppColors.mutedForeground),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
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
    setState(() {}); // Rebuild for clear icon visibility
  }

  Widget _buildFilterButton(DiscoverLoaded state) {
    final filterCount = state.activeFilterCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        OutlinedButton.icon(
          onPressed: () => _showFilterDialog(state),
          icon: const Icon(Icons.tune, size: 16),
          label: Text(
            l10n.filters,
            style: TextStyle(fontSize: 14, color: AppColors.foreground),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        if (filterCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$filterCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(DiscoverLoaded state) {
    final hasActiveFilters = state.activeFilterCount > 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.selectedCity == null
                  ? Icons.location_city
                  : hasActiveFilters
                      ? Icons.filter_list_off
                      : Icons.search_off,
              size: 64,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              state.selectedCity == null
                  ? l10n.selectCityToViewInventory
                  : hasActiveFilters
                      ? l10n.noResultsWithFilters
                      : l10n.noInventoryFound,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            if (state.selectedCity != null) ...[
              const SizedBox(height: 8),
              if (!hasActiveFilters)
                Text(
                  '${state.selectedCity!.name} - ${l10n.noAvailableBillboards}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              if (hasActiveFilters)
                ElevatedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    context.read<DiscoverBloc>().add(ResetFilters());
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.resetFilters),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: () {
                    final belgrade = state.cities
                        .where((c) => c.name.toLowerCase() == 'belgrade' || c.name.toLowerCase() == 'beograd')
                        .firstOrNull;
                    if (belgrade != null) {
                      context.read<DiscoverBloc>().add(SelectCity(belgrade));
                    }
                  },
                  icon: const Icon(Icons.explore),
                  label: Text(l10n.exploreBelgrade),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.muted,
      child: Center(
        child: Icon(Icons.image, size: 32, color: AppColors.mutedForeground),
      ),
    );
  }

  Widget _buildMapSection(DiscoverLoaded state) {
    // Determine map center and zoom based on selection
    final LatLng center;
    final double zoom;

    if (state.selectedCity != null) {
      // City selected — zoom to city
      center = LatLng(state.selectedCity!.latitude, state.selectedCity!.longitude);
      zoom = 12.0;
    } else if (state.selectedCountry != null && state.cities.isNotEmpty) {
      // Country selected but no city — center on first city of that country
      center = LatLng(state.cities.first.latitude, state.cities.first.longitude);
      zoom = 7.0;
    } else {
      // "All countries" — show Balkans overview
      center = const LatLng(44.0, 18.5);
      zoom = 6.0;
    }

    return InventoryMap(
      units: state.units,
      center: center,
      zoom: zoom,
      selectedUnit: _selectedUnit,
      onUnitTap: (unit) {
        setState(() {
          if (_selectedUnit?.id == unit.id) {
            _selectedUnit = null;
          } else {
            _selectedUnit = unit;
          }
        });
      },
      onUnitDetailTap: (unit) => _navigateToDetail(unit),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.destructive),
          const SizedBox(height: 16),
          Text(
              l10n.error,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<DiscoverBloc>().add(const LoadCities()),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(DiscoverLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return FilterBottomSheet(
          unitTypes: state.unitTypes,
          mediaFormats: state.mediaFormats,
          venueTypes: state.venueTypes,
          currentFilters: state.activeFilters,
          onApply: (filters) {
            context.read<DiscoverBloc>().add(ApplyFilters(filters));
            // Sync search field with keyword from filters
            if (filters.keyword != null && filters.keyword != _searchController.text) {
              _searchController.text = filters.keyword!;
            } else if (filters.keyword == null && _searchController.text.isNotEmpty) {
              _searchController.clear();
            }
          },
          onReset: () {
            _searchController.clear();
            context.read<DiscoverBloc>().add(ResetFilters());
          },
        );
      },
    );
  }

  void _navigateToDetail(OohUnit unit) {
    context.push('/discover/${unit.id}');
  }
}
