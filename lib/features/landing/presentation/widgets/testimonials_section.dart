import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/responsive/responsive.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  static const List<Map<String, String>> testimonials = [
    {
      'name': 'Sarah Johnson',
      'role': 'Marketing Director, Nova',
      'avatar': 'SJ',
      'quote':
          'The platform\'s planning tools are a game-changer. We were able to identify and book high-performing locations that we otherwise missed. Our campaign ROI exceeded all expectations.',
    },
    {
      'name': 'James Chen',
      'role': 'CEO, Bright Solutions',
      'avatar': 'JC',
      'quote':
          'It\'s incredibly intuitive and powerful tool for OOH advertising. The process from discovery to booking was seamless, and the customer support was top-notch throughout.',
    },
    {
      'name': 'Emily Rodriguez',
      'role': 'Brand Manager, Luxe',
      'avatar': 'ER',
      'quote':
          'We reached a massive, targeted audience for our new product launch. The analytics provided a clear picture of impact, which was crucial for our stakeholders.',
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
          children: [
            Text(
              'Trusted by innovative brands',
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
              'From high-growth startups to Fortune 500 companies, we\'re the trusted partner for impactful out-of-home advertising.',
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
      children: testimonials.asMap().entries.map((entry) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: entry.key < testimonials.length - 1 ? 16 : 0,
          ),
          child: _TestimonialCard(
            testimonial: entry.value,
            delay: entry.key * 100,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabletLayout() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.9,
      ),
      itemCount: testimonials.length,
      itemBuilder: (context, index) {
        return _TestimonialCard(
          testimonial: testimonials[index],
          delay: index * 100,
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: testimonials.length,
      itemBuilder: (context, index) {
        return _TestimonialCard(
          testimonial: testimonials[index],
          delay: index * 100,
        );
      },
    );
  }
}

class _TestimonialCard extends StatefulWidget {
  final Map<String, String> testimonial;
  final int delay;

  const _TestimonialCard({
    required this.testimonial,
    required this.delay,
  });

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()
          ..translateByDouble(0.0, _isHovered ? -8.0 : 0.0, 0.0, 1.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
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
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.testimonial['avatar']!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.testimonial['name']!,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.testimonial['role']!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '"${widget.testimonial['quote']}"',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.mutedForeground,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms, delay: Duration(milliseconds: widget.delay))
          .slideY(begin: 0.2, end: 0),
    );
  }
}
