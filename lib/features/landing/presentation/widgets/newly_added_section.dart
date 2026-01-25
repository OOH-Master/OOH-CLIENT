import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/responsive/responsive.dart';

class NewlyAddedSection extends StatelessWidget {
  const NewlyAddedSection({super.key});

  static const List<Map<String, dynamic>> mediaListings = [
    {
      'id': '1',
      'title': 'Highway Billboard I-95',
      'location': 'New York, NY',
      'price': 150000,
      'priceUnit': 'month',
    },
    {
      'id': '2',
      'title': 'Mall Facade, Downtown',
      'location': 'New York, NY',
      'price': 200000,
      'priceUnit': 'month',
    },
    {
      'id': '3',
      'title': 'Grand Central Terminal Screen',
      'location': 'New York, NY',
      'price': 70000,
      'priceUnit': 'month',
    },
    {
      'id': '4',
      'title': 'Times Square Digital Tower',
      'location': 'New York, NY',
      'price': 500000,
      'priceUnit': 'month',
    },
    {
      'id': '5',
      'title': 'LAX Terminal 4 Network',
      'location': 'Los Angeles, CA',
      'price': 85000,
      'priceUnit': 'month',
    },
    {
      'id': '6',
      'title': 'Chicago Bus Shelter Network',
      'location': 'Chicago, IL',
      'price': 45000,
      'priceUnit': 'month',
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Newly Added Media',
                  style: context.isDesktop
                      ? AppTypography.displaySmall
                      : AppTypography.h1,
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Explore the latest OOH opportunities on our platform.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mediaListings.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < mediaListings.length - 1 ? 24 : 0,
                    ),
                    child: _MediaListingCard(
                      listing: mediaListings[index],
                      delay: index * 100,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaListingCard extends StatefulWidget {
  final Map<String, dynamic> listing;
  final int delay;

  const _MediaListingCard({
    required this.listing,
    required this.delay,
  });

  @override
  State<_MediaListingCard> createState() => _MediaListingCardState();
}

class _MediaListingCardState extends State<_MediaListingCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {},
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.7),
                        AppColors.accent.withOpacity(0.5),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.location_city,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                // Content
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.listing['title'],
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.listing['location'],
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${_formatPrice(widget.listing['price'])}/${widget.listing['priceUnit']}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
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
            .slideX(begin: 0.2, end: 0, duration: 600.ms, delay: Duration(milliseconds: widget.delay)),

    );
  }

  String _formatPrice(int price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toString();
  }
}
