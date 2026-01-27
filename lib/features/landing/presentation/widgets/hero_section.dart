import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../discover/domain/entities/city.dart';
import '../../../discover/presentation/blocs/discover_bloc.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  static const List<String> _keywordKeys = [
    'heroKeywordBusStation',
    'heroKeywordShoppingMall',
    'heroKeywordMetro',
    'heroKeywordAirport',
    'heroKeywordDigitalBillboard',
    'heroKeywordAnamorphic',
    'heroKeywordWrapping',
    'heroKeywordElectronic',
  ];

  static const List<String> _pillKeys = [
    'heroKeywordBusStation',
    'heroKeywordMetro',
    'heroKeywordShoppingMall',
    'heroKeywordAirport',
    'heroKeywordDigitalBillboard',
    'heroKeywordAnamorphic',
    'heroKeywordWrapping',
    'heroKeywordElectronic',
  ];

  int _currentKeywordIndex = 0;
  City? _selectedCity;
  String? _selectedPillKey;

  @override
  void initState() {
    super.initState();
    _startKeywordAnimation();
    // Load cities when hero section loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoverBloc>().add(const LoadCities());
    });
  }

  void _startKeywordAnimation() {
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _currentKeywordIndex = (_currentKeywordIndex + 1) % _keywordKeys.length;
        });
        _startKeywordAnimation();
      }
    });
  }

  void _handleSearch() {
    if (_selectedCity != null) {
      context.go('/discover?cityId=${_selectedCity!.id}');
    } else {
      context.go('/discover');
    }
  }

  void _handleSeeMap() {
    context.go('/discover');
  }

  void _scrollToCategoriesSection() {
    // Scroll to categories (not implemented)
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final keywordLabels = _keywordKeys.map((key) => _keywordLabel(key, l10n)).toList();
    final pillLabels = _pillKeys.map((key) => _keywordLabel(key, l10n)).toList();

    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final bool isMobile = deviceType == DeviceType.mobile;
        
        return Container(
          height: isMobile ? MediaQuery.of(context).size.height * 0.8 : MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=1920',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: context.responsivePadding,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),

                          // Animated headline
                          _buildAnimatedHeadline(isMobile, keywordLabels, l10n),

                          SizedBox(height: isMobile ? AppSpacing.md : AppSpacing.lg),

                          // Subheadline
                          Text(
                            l10n.heroSubheadlineShort,
                            style: AppTypography.lead.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.3, end: 0),

                          SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),

                          // Search form with cities
                          _buildSearchForm(isMobile, l10n),

                          SizedBox(height: isMobile ? AppSpacing.md : AppSpacing.lg),

                          // Pills
                          _buildPills(pillLabels),

                          SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),

                          // CTA buttons
                          _buildCTAButtons(isMobile, l10n),

                          SizedBox(height: isMobile ? AppSpacing.xl : AppSpacing.xxl),

                          // Scroll down button
                          _buildScrollDownButton(l10n),

                          SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHeadline(bool isMobile, List<String> keywordLabels, AppLocalizations l10n) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            keywordLabels[_currentKeywordIndex],
            key: ValueKey(_currentKeywordIndex),
            style: (isMobile ? AppTypography.displaySmall : AppTypography.displayLarge).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          l10n.heroHeadlineQuestion,
          style: (isMobile ? AppTypography.displaySmall : AppTypography.displayLarge).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildSearchForm(bool isMobile, AppLocalizations l10n) {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        List<City> cities = [];
        City? selectedCity;

        if (state is DiscoverLoaded) {
          cities = state.cities;

          // Validate that _selectedCity exists in current cities list
          if (_selectedCity != null && cities.isNotEmpty) {
            final exists = cities.any((c) => c.id == _selectedCity!.id);
            if (exists) {
              selectedCity = cities.firstWhere((c) => c.id == _selectedCity!.id);
            }
          }

          // Set default city if not set
          if (selectedCity == null && cities.isNotEmpty) {
            selectedCity = cities.firstWhere(
              (c) => c.name.toLowerCase().contains('belgrade') || c.name.toLowerCase().contains('beograd'),
              orElse: () => cities.first,
            );
            _selectedCity = selectedCity;
          }
        }

        return Container(
          constraints: const BoxConstraints(maxWidth: 768),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // City dropdown
              Container(
                width: 180,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.border),
                ),
                child: cities.isEmpty
                    ? Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<City>(
                          value: selectedCity,
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.foreground),
                          icon: Icon(Icons.arrow_drop_down, color: AppColors.foreground, size: 20),
                          items: cities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(
                                '${city.name}, ${city.country}',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.foreground,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCity = value;
                            });
                          },
                        ),
                      ),
              ),

              SizedBox(width: AppSpacing.xs),

              // Search input
              Expanded(
                child: TextField(
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
                  decoration: InputDecoration(
                    hintText: l10n.searchLocationsPlaceholder,
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onSubmitted: (_) => _handleSearch(),
                ),
              ),

              // Search button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: IconButton(
                  onPressed: _handleSearch,
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3, end: 0);
      },
    );
  }

  Widget _buildPills(List<String> pillLabels) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(pillLabels.length, (index) {
        final key = _pillKeys[index];
        final label = pillLabels[index];
        final isSelected = _selectedPillKey == key;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPillKey = isSelected ? null : key;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }),
    )
        .animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildCTAButtons(bool isMobile, AppLocalizations l10n) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _handleSeeMap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? AppSpacing.lg : AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          icon: const Icon(Icons.map_outlined),
          label: Text(
            l10n.seeMap,
            style: AppTypography.button.copyWith(color: Colors.white),
          ),
        ),
      ],
    )
        .animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildScrollDownButton(AppLocalizations l10n) {
    return IconButton(
      onPressed: _scrollToCategoriesSection,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Colors.white.withValues(alpha: 0.7),
        size: 32,
      ),
      tooltip: l10n.scrollDown,
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 1000.ms)
        .slideY(begin: -0.05, end: 0.05);
  }

  String _keywordLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'heroKeywordBusStation':
        return l10n.heroKeywordBusStation;
      case 'heroKeywordShoppingMall':
        return l10n.heroKeywordShoppingMall;
      case 'heroKeywordMetro':
        return l10n.heroKeywordMetro;
      case 'heroKeywordAirport':
        return l10n.heroKeywordAirport;
      case 'heroKeywordDigitalBillboard':
        return l10n.heroKeywordDigitalBillboard;
      case 'heroKeywordAnamorphic':
        return l10n.heroKeywordAnamorphic;
      case 'heroKeywordWrapping':
        return l10n.heroKeywordWrapping;
      case 'heroKeywordElectronic':
        return l10n.heroKeywordElectronic;
      default:
        return key;
    }
  }
}
