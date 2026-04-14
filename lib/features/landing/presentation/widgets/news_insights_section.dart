import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';

class NewsInsightsSection extends StatelessWidget {
  const NewsInsightsSection({super.key});

  static const List<Map<String, String>> articles = [
    {
      'title': 'OOH for the Performance Age: The Intersection of Media and Art',
      'date': 'Nov 24',
    },
    {
      'title': 'Delivering Seamless OOH Campaigns in a Fragmented Media Landscape',
      'date': 'Nov 18',
    },
  ];

  static const List<Map<String, dynamic>> trendingTopics = [
    {
      'icon': Icons.trending_up,
      'title': 'How Activating Large-Scale Audience Measurement is OOH',
    },
    {
      'icon': Icons.people,
      'title': 'The Rise of Sustainable Production Elements in OOH',
    },
    {
      'icon': Icons.bar_chart,
      'title': 'Why US Programmatic Billboards are Capturing Public Imagination',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.muted,
      padding: EdgeInsets.symmetric(
        vertical: context.isDesktop ? 96 : 64,
        horizontal: context.isDesktop ? 48 : 16,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Column(
          children: [
            Text(
              'News & Insights',
              style: context.isDesktop
                  ? AppTypography.displaySmall
                  : AppTypography.h1,
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            Text(
              'Stay ahead of the curve with the latest from the OOH world.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 600.ms),
            const SizedBox(height: 48),
            ResponsiveLayout(
              mobile: _buildMobileLayout(),
              tablet: _buildTabletLayout(),
              desktop: _buildDesktopLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...articles.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: entry.key < articles.length - 1 ? 16 : 0,
            ),
            child: _ArticleCard(
              article: entry.value,
              delay: entry.key * 100,
            ),
          );
        }),
        const SizedBox(height: 32),
        _buildTrendingTopics(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 1.2,
          ),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            return _ArticleCard(
              article: articles[index],
              delay: index * 100,
            );
          },
        ),
        const SizedBox(height: 32),
        _buildTrendingTopics(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 1.1,
            ),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return _ArticleCard(
                article: articles[index],
                delay: index * 100,
              );
            },
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 1,
          child: _buildTrendingTopics(),
        ),
      ],
    );
  }

  Widget _buildTrendingTopics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trending Posts',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.w600,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms),
        const SizedBox(height: 16),
        ...trendingTopics.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: entry.key < trendingTopics.length - 1 ? 16 : 0,
            ),
            child: _TrendingTopicItem(
              topic: entry.value,
              delay: entry.key * 100,
            ),
          );
        }),
      ],
    );
  }
}

class _ArticleCard extends StatefulWidget {
  final Map<String, String> article;
  final int delay;

  const _ArticleCard({
    required this.article,
    required this.delay,
  });

  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()
            ..translateByDouble(0.0, _isHovered ? -8.0 : 0.0, 0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _isHovered ? 0.15 : 0.05),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: Offset(0, _isHovered ? 10 : 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.7),
                        AppColors.accent.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.article,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.article['title']!,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _isHovered
                              ? AppColors.primary
                              : AppColors.foreground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.article['date']!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms, delay: Duration(milliseconds: widget.delay))
          .slideY(begin: 0.2, end: 0),
    );
  }
}

class _TrendingTopicItem extends StatefulWidget {
  final Map<String, dynamic> topic;
  final int delay;

  const _TrendingTopicItem({
    required this.topic,
    required this.delay,
  });

  @override
  State<_TrendingTopicItem> createState() => _TrendingTopicItemState();
}

class _TrendingTopicItemState extends State<_TrendingTopicItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                widget.topic['icon'] as IconData,
                size: 16,
                color: _isHovered
                    ? AppColors.primary
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.topic['title'],
                style: AppTypography.bodySmall.copyWith(
                  color: _isHovered
                      ? AppColors.foreground
                      : AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms, delay: Duration(milliseconds: widget.delay))
          .slideX(begin: -0.2, end: 0),
    );
  }
}
