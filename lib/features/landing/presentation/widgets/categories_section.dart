import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/responsive/responsive.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  static const List<Map<String, String>> categories = [
    {
      'id': '1',
      'title': 'Digital Billboards',
      'subtitle': 'High-impact digital displays in prime locations',
      'image': 'assets/images/digital_billboard.jpg',
    },
    {
      'id': '2',
      'title': 'Subway Screens',
      'subtitle': 'Engage commuters in high-traffic stations',
      'image': 'assets/images/subway.jpg',
    },
    {
      'id': '3',
      'title': 'Bus Shelters',
      'subtitle': 'Street-level advertising on transit shelters',
      'image': 'assets/images/bus_shelter.jpg',
    },
    {
      'id': '4',
      'title': 'Airports',
      'subtitle': 'Connect with global traveler audiences',
      'image': 'assets/images/airport.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        vertical: context.isDesktop ? 96 : 64,
        horizontal: context.isDesktop ? 48 : 16,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Istražite kategorije',
              style: context.isDesktop
                  ? AppTypography.displaySmall.copyWith(fontWeight: FontWeight.w700)
                  : AppTypography.h1.copyWith(fontWeight: FontWeight.w700),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              'Pronađite idealan oglasni prostor za vašu kampanju.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.mutedForeground,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 600.ms),
            const SizedBox(height: 40),
            ResponsiveLayout(
              mobile: _buildMobileGrid(),
              tablet: _buildTabletGrid(),
              desktop: _buildDesktopGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 16 / 9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _CategoryCard(
          category: categories[index],
          delay: index * 100,
        );
      },
    );
  }

  Widget _buildTabletGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 16 / 10,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _CategoryCard(
          category: categories[index],
          delay: index * 100,
        );
      },
    );
  }

  Widget _buildDesktopGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 3 / 4,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _CategoryCard(
          category: categories[index],
          delay: index * 100,
        );
      },
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final Map<String, String> category;
  final int delay;

  const _CategoryCard({
    required this.category,
    required this.delay,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                AnimatedScale(
                  scale: _isHovered ? 1.1 : 1.0,
                  duration: AppDuration.normal,
                  curve: Curves.easeInOut,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.7),
                          AppColors.accent.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                    child: Icon(
                      _getCategoryIcon(widget.category['id']!),
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category['title']!,
                        style: AppTypography.h3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.category['subtitle']!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: Duration(milliseconds: widget.delay))
            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: Duration(milliseconds: widget.delay)),
      ),
    );
  }

  IconData _getCategoryIcon(String id) {
    switch (id) {
      case '1':
        return Icons.tv;
      case '2':
        return Icons.subway;
      case '3':
        return Icons.bus_alert;
      case '4':
        return Icons.flight;
      default:
        return Icons.ads_click;
    }
  }
}
