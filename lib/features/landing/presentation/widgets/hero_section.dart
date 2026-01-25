import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  final List<String> heroKeywords = [
    'Bus station',
    'Shopping mall',
    'Metro',
    'Airport',
    'Digital billboard',
    'Anamorphic',
    'Wrapping',
  ];

  int _currentKeywordIndex = 0;
  String _selectedCountry = 'Republic of Korea';
  String _searchQuery = '';
  String? _selectedPill;

  final List<String> pillOptions = [
    'Bus station',
    'Metro',
    'Shopping mall',
    'Airport',
    'Digital',
    'Anamorphic',
    'Wrapping',
    'Electronic',
  ];

  @override
  void initState() {
    super.initState();
    _startKeywordAnimation();
  }

  void _startKeywordAnimation() {
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _currentKeywordIndex = (_currentKeywordIndex + 1) % heroKeywords.length;
        });
        _startKeywordAnimation();
      }
    });
  }

  void _handleSearch() {
    // TODO: Navigate to search page with params
    print('Search: country=$_selectedCountry, query=$_searchQuery, pill=$_selectedPill');
  }

  void _handleSeeMap() {
    // TODO: Navigate to map view
    print('See Map clicked');
  }

  void _scrollToCategoriesSection() {
    // TODO: Scroll to categories section
    print('Scroll to categories');
  }

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated headline
                    _buildAnimatedHeadline(isMobile),
                    
                    SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
                    
                    // Subheadline
                    Text(
                      'Discover and filter available inventory in seconds.',
                      style: AppTypography.lead.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 0.3, end: 0),
                    
                    SizedBox(height: isMobile ? AppSpacing.xl : AppSpacing.xxl),
                    
                    // Search form
                    _buildSearchForm(isMobile),
                    
                    SizedBox(height: AppSpacing.lg),
                    
                    // Pills
                    _buildPills(),
                    
                    SizedBox(height: AppSpacing.xl),
                    
                    // CTA buttons
                    _buildCTAButtons(isMobile),
                    
                    const Spacer(),
                    
                    // Scroll down button
                    _buildScrollDownButton(),
                    
                    SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHeadline(bool isMobile) {
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
            heroKeywords[_currentKeywordIndex],
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
          'Are you looking for media?',
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

  Widget _buildSearchForm(bool isMobile) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 768),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          // Country dropdown
          Container(
            width: 190,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountry,
                dropdownColor: Colors.white,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                items: [
                  'Republic of Korea',
                  'United States',
                  'United Kingdom',
                  'Germany',
                  'France',
                ].map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(
                      country,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value!;
                  });
                },
              ),
            ),
          ),
          
          SizedBox(width: AppSpacing.xs),
          
          // Search input
          Expanded(
            child: TextField(
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search locations...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.6),
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

  Widget _buildPills() {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      alignment: WrapAlignment.center,
      children: pillOptions.map((pill) {
        final isSelected = _selectedPill == pill;
        return FilterChip(
          label: Text(pill),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedPill = selected ? pill : null;
            });
          },
          backgroundColor: Colors.white.withOpacity(0.1),
          selectedColor: AppColors.primary,
          labelStyle: AppTypography.bodySmall.copyWith(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.3),
          ),
        );
      }).toList(),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildCTAButtons(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: _handleSeeMap,
            icon: const Icon(Icons.map),
            label: const Text('See Map'),
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
          label: const Text('See Map'),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 500.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildScrollDownButton() {
    return IconButton(
      onPressed: _scrollToCategoriesSection,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Colors.white.withOpacity(0.7),
        size: 32,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 1000.ms)
        .then()
        .fadeOut(duration: 1000.ms);
  }
}
