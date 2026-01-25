import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/hero_section.dart';
import '../widgets/categories_section.dart';
import '../widgets/newly_added_section.dart';
import '../widgets/advanced_analytics_section.dart';
import '../widgets/expert_advice_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/news_insights_section.dart';
import '../widgets/cta_section.dart';
import '../widgets/app_footer.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),
            CategoriesSection(),
            NewlyAddedSection(),
            AdvancedAnalyticsSection(),
            ExpertAdviceSection(),
            TestimonialsSection(),
            NewsInsightsSection(),
            CTASection(),
            AppFooter(),
          ],
        ),
      ),
    );
  }
}
