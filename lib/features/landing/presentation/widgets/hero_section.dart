import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/responsive/responsive.dart';

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

  static const List<String> _countryCodes = [
    'korea',
    'usa',
    'uk',
    'germany',
    'france',
  ];

  int _currentKeywordIndex = 0;
  String _selectedCountryCode = 'korea';
  String _searchQuery = '';
  String? _selectedPillKey;

  @override
  void initState() {
    super.initState();
    _startKeywordAnimation();
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
    // Navigate to discover page
    context.go('/discover');
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
    final countryLabels = _countryCodes.map((code) => _countryLabel(code, l10n)).toList();

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
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.55),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: context.responsivePadding,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
                      
                      // Animated headline
                      _buildAnimatedHeadline(isMobile),
                      
                      SizedBox(height: isMobile ? AppSpacing.md : AppSpacing.lg),
                      
                      // Subheadline
                      Text(
                        l10n.heroSubheadlineShort,
                        style: AppTypography.lead.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: 0.3, end: 0),
                      
                      SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
                      
                      // Search form
                      _buildSearchForm(isMobile, l10n, countryLabels),
                      
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
        );
      },
    );
  }

  Widget _buildAnimatedHeadline(bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    final keywordLabels = _keywordKeys.map((key) => _keywordLabel(key, l10n)).toList();
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

  Widget _buildSearchForm(bool isMobile, AppLocalizations l10n, List<String> countryLabels) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 768),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Country dropdown
          Container(
            width: 160,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountryCode,
                dropdownColor: Colors.white,
                isExpanded: true,
                style: AppTypography.bodySmall.copyWith(color: AppColors.foreground),
                icon: Icon(Icons.arrow_drop_down, color: AppColors.foreground, size: 20),
                items: List.generate(_countryCodes.length, (index) {
                  final code = _countryCodes[index];
                  return DropdownMenuItem(
                    value: code,
                    child: Text(
                      countryLabels[index],
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedCountryCode = value!;
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Search button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: _handleSearch,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 300.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildPills(List<String> pillLabels) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      alignment: WrapAlignment.center,
      children: List.generate(_pillKeys.length, (index) {
        final pillKey = _pillKeys[index];
        final pill = pillLabels[index];
        final isSelected = _selectedPillKey == pillKey;
        return FilterChip(
          label: Text(pill),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedPillKey = selected ? pillKey : null;
            });
          },
          backgroundColor: Colors.white.withOpacity(0.9),
          selectedColor: AppColors.primary,
          labelStyle: AppTypography.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.foreground,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        );
      }).toList(),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildCTAButtons(bool isMobile, AppLocalizations l10n) {
    if (isMobile) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: _handleSeeMap,
            icon: const Icon(Icons.map),
            label: Text(l10n.seeMap),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _handleSeeMap,
          icon: const Icon(Icons.map),
          label: Text(l10n.seeMap),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 500.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildScrollDownButton(AppLocalizations l10n) {
    return IconButton(
      onPressed: _scrollToCategoriesSection,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Colors.white.withOpacity(0.7),
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

  String _countryLabel(String code, AppLocalizations l10n) {
    switch (code) {
      case 'korea':
        return l10n.countryKorea;
      case 'usa':
        return l10n.countryUSA;
      case 'uk':
        return l10n.countryUK;
      case 'germany':
        return l10n.countryGermany;
      case 'france':
        return l10n.countryFrance;
      default:
        return code;
    }
  }
}
