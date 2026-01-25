# Reusable Widgets Documentation

## Overview

This document catalogs all reusable widgets in the OOH Mobile application. Widgets are organized by category and include usage examples, parameters, and best practices.

## Widget Categories

- [Core Widgets](#core-widgets) - Basic UI components
- [Form Widgets](#form-widgets) - Input and form elements
- [Landing Widgets](#landing-widgets) - Landing page components
- [Layout Widgets](#layout-widgets) - Structural components

---

## Core Widgets

Location: `lib/core/widgets/`

### AppButton

Custom button widget with multiple variants and consistent styling.

**Location**: `lib/core/widgets/app_button.dart`

**Variants**:
- Primary (Elevated)
- Secondary (Outlined)
- Tertiary (Text)

**Parameters**:
```dart
AppButton({
  required String text,
  required VoidCallback onPressed,
  ButtonVariant variant = ButtonVariant.primary,
  bool isLoading = false,
  bool isFullWidth = false,
  IconData? icon,
})
```

**Usage**:
```dart
// Primary button
AppButton(
  text: 'Get Started',
  onPressed: () {},
)

// Secondary button with icon
AppButton(
  text: 'Learn More',
  variant: ButtonVariant.secondary,
  icon: Icons.info_outline,
  onPressed: () {},
)

// Loading state
AppButton(
  text: 'Submitting...',
  isLoading: true,
  onPressed: null,
)
```

### AppTextField

Custom text input field with built-in validation and consistent styling.

**Location**: `lib/core/widgets/app_text_field.dart`

**Parameters**:
```dart
AppTextField({
  required TextEditingController controller,
  String? label,
  String? hint,
  IconData? prefixIcon,
  IconData? suffixIcon,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  VoidCallback? onSuffixIconTap,
})
```

**Usage**:
```dart
// Email field
AppTextField(
  controller: _emailController,
  label: 'Email',
  hint: 'Enter your email',
  prefixIcon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    if (!value!.contains('@')) return 'Invalid email';
    return null;
  },
)

// Password field
AppTextField(
  controller: _passwordController,
  label: 'Password',
  obscureText: !_isPasswordVisible,
  prefixIcon: Icons.lock_outlined,
  suffixIcon: _isPasswordVisible 
      ? Icons.visibility_off 
      : Icons.visibility,
  onSuffixIconTap: () {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  },
)
```

### AppScaffold

Custom scaffold with consistent structure and navigation.

**Location**: `lib/core/widgets/app_scaffold.dart`

**Parameters**:
```dart
AppScaffold({
  required Widget body,
  String? title,
  List<Widget>? actions,
  Widget? floatingActionButton,
  Widget? bottomNavigationBar,
  bool showAppBar = true,
})
```

**Usage**:
```dart
AppScaffold(
  title: 'Discover',
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
  ],
  body: DiscoverContent(),
)
```

### AppSnackbar

Utility for showing consistent snackbar messages.

**Location**: `lib/core/widgets/app_snackbar.dart`

**Methods**:
```dart
AppSnackbar.success(BuildContext context, String message)
AppSnackbar.error(BuildContext context, String message)
AppSnackbar.info(BuildContext context, String message)
AppSnackbar.warning(BuildContext context, String message)
```

**Usage**:
```dart
// Success message
AppSnackbar.success(context, 'Login successful!');

// Error message
AppSnackbar.error(context, 'Failed to load data');

// Info message
AppSnackbar.info(context, 'New feature available');

// Warning message
AppSnackbar.warning(context, 'Session will expire soon');
```

---

## Landing Widgets

Location: `lib/features/landing/presentation/widgets/`

### AppHeader

Navigation header with logo, menu, and auth buttons.

**Location**: `lib/features/landing/presentation/widgets/app_header.dart`

**Features**:
- Desktop horizontal navigation
- Mobile hamburger menu
- Smooth scroll to sections
- Login/Register buttons

**Usage**:
```dart
AppHeader()  // No parameters needed
```

**Responsive Behavior**:
- **Mobile** (<640px): Hamburger menu, vertical navigation drawer
- **Desktop** (≥640px): Horizontal navigation bar

### HeroSection

Landing page hero with animated rotating keywords and search.

**Location**: `lib/features/landing/presentation/widgets/hero_section.dart`

**Features**:
- 7 rotating keywords (2.2s interval)
- Country dropdown selector
- Search input field
- 8 category filter pills
- Gradient background with overlay

**Keywords**:
- Billboards
- Subways
- Airports
- Malls
- Streets
- Stadiums
- Stations

**Usage**:
```dart
HeroSection()
```

### CategoriesSection

Grid of OOH advertising categories with gradient cards.

**Location**: `lib/features/landing/presentation/widgets/categories_section.dart`

**Categories**:
1. **Digital Billboards** (Blue gradient)
2. **Subway Advertising** (Purple gradient)
3. **Bus Shelters** (Indigo gradient)
4. **Airport Displays** (Pink gradient)

**Features**:
- Hover scale animation (1.02x)
- 300ms smooth transition
- Icons with semantic meaning
- Browse buttons with arrow icons

**Usage**:
```dart
CategoriesSection()
```

**Responsive Grid**:
- **Mobile**: 1 column
- **Tablet**: 2 columns
- **Desktop**: 4 columns

### NewlyAddedSection

Horizontal scrolling carousel of media listings.

**Location**: `lib/features/landing/presentation/widgets/newly_added_section.dart`

**Features**:
- 6 sample media cards
- Price formatting ($X,XXX/month)
- Location display
- Horizontal scroll
- Card hover effects

**Card Properties**:
- Image thumbnail
- Media name
- Location (city, country)
- Monthly price

**Usage**:
```dart
NewlyAddedSection()
```

### AdvancedAnalyticsSection

Two-column section showcasing analytics features.

**Location**: `lib/features/landing/presentation/widgets/advanced_analytics_section.dart`

**Features**:
- Feature list with checkmarks
- CTA button
- Gradient chart mockup
- Responsive layout

**Feature List**:
- Real-time performance tracking
- Audience demographics
- ROI calculations
- Competitor analysis

**Usage**:
```dart
AdvancedAnalyticsSection()
```

**Responsive Layout**:
- **Mobile**: Stacked (text above, image below)
- **Desktop**: Side-by-side (60/40 split)

### ExpertAdviceSection

Mobile app mockup showcase with feature cards.

**Location**: `lib/features/landing/presentation/widgets/expert_advice_section.dart`

**Features**:
- Phone frame mockup (9:19.5 ratio)
- Expert Support icon with pulse
- 2 floating feature cards
- Responsive sizing

**Feature Cards**:
1. **Campaign Analytics** - Track performance
2. **Performance Insights** - Optimize reach

**Usage**:
```dart
ExpertAdviceSection()
```

### TestimonialsSection

Grid of customer testimonials.

**Location**: `lib/features/landing/presentation/widgets/testimonials_section.dart`

**Features**:
- 3 testimonials
- Circular avatars
- Name, role, company
- Quote text
- Star ratings (optional)

**Testimonial Structure**:
```dart
{
  'name': 'Sarah Johnson',
  'role': 'Marketing Director',
  'company': 'TechCorp Inc.',
  'quote': 'This platform transformed our OOH strategy...',
  'avatar': 'S',
}
```

**Usage**:
```dart
TestimonialsSection()
```

**Responsive Grid**:
- **Mobile**: 1 column
- **Tablet**: 2 columns
- **Desktop**: 3 columns

### NewsInsightsSection

Blog articles and trending topics sidebar.

**Location**: `lib/features/landing/presentation/widgets/news_insights_section.dart`

**Features**:
- 2 featured articles
- 3 trending topics
- Read time estimates
- Category badges
- Thumbnail images

**Layout**:
- **Main**: 2 article cards (2:1 ratio)
- **Sidebar**: Trending topics list

**Usage**:
```dart
NewsInsightsSection()
```

**Responsive Layout**:
- **Mobile**: Stacked (articles, then trending)
- **Desktop**: 70/30 split

### CTASection

Final call-to-action section.

**Location**: `lib/features/landing/presentation/widgets/cta_section.dart`

**Features**:
- Centered content
- Large headline
- Primary CTA button
- Gradient background

**Usage**:
```dart
CTASection()
```

### AppFooter

Site footer with link columns and copyright.

**Location**: `lib/features/landing/presentation/widgets/app_footer.dart`

**Columns**:
1. **Solutions** - Discover, Analytics, Reports
2. **Products** - Billboard, Subway, Airport, Mall
3. **Resources** - Documentation, API, Support, Community
4. **Company** - About, Blog, Careers, Contact

**Features**:
- 4-column layout
- Link hover states
- Social media icons (optional)
- Copyright notice

**Usage**:
```dart
AppFooter()
```

**Responsive Layout**:
- **Mobile**: Stacked columns (1 per row)
- **Tablet**: 2 columns per row
- **Desktop**: 4 columns per row

---

## Layout Widgets

### ResponsiveLayout

Adaptive layout builder for different screen sizes.

**Parameters**:
```dart
ResponsiveLayout({
  required Widget mobile,
  Widget? tablet,
  required Widget desktop,
})
```

**Usage**:
```dart
ResponsiveLayout(
  mobile: MobileLayout(),
  tablet: TabletLayout(),  // Optional
  desktop: DesktopLayout(),
)
```

### MaxWidthContainer

Container with maximum width constraint for content.

**Parameters**:
```dart
MaxWidthContainer({
  required Widget child,
  double maxWidth = 1280,
  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 24),
})
```

**Usage**:
```dart
MaxWidthContainer(
  maxWidth: 1200,
  child: content,
)
```

---

## Best Practices

### 1. Widget Composition

✅ **Do** - Compose small, reusable widgets:
```dart
class ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ProfileAvatar(),
          ProfileName(),
          ProfileStats(),
        ],
      ),
    );
  }
}
```

❌ **Don't** - Create monolithic widgets:
```dart
// Avoid 500+ line widgets
```

### 2. Const Constructors

✅ **Do** - Use const when possible:
```dart
const AppButton(text: 'Submit', onPressed: _submit)
```

❌ **Don't** - Skip const unnecessarily:
```dart
AppButton(text: 'Submit', onPressed: _submit)
```

### 3. Named Parameters

✅ **Do** - Use named parameters for clarity:
```dart
AppTextField(
  controller: _controller,
  label: 'Email',
  validator: _validate,
)
```

❌ **Don't** - Use positional parameters for complex widgets:
```dart
AppTextField(_controller, 'Email', _validate)
```

### 4. Widget Keys

✅ **Do** - Use keys for list items:
```dart
ListView.builder(
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index].id),
      title: Text(items[index].name),
    );
  },
)
```

### 5. Extract Methods

✅ **Do** - Extract complex widget trees:
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildContent(),
        _buildFooter(),
      ],
    );
  }
  
  Widget _buildHeader() => /* ... */;
  Widget _buildContent() => /* ... */;
  Widget _buildFooter() => /* ... */;
}
```

---

## Widget Lifecycle

### StatelessWidget

```dart
class MyStatelessWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

**When to use**:
- No internal state
- Depends only on configuration
- Rebuilds when parent rebuilds

### StatefulWidget

```dart
class MyStatefulWidget extends StatefulWidget {
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize state
  }
  
  @override
  void dispose() {
    // Clean up
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

**When to use**:
- Has internal mutable state
- Needs lifecycle methods
- Manages animations or controllers

---

## Performance Tips

1. **Use const constructors** - Reduces widget rebuilds
2. **Extract static widgets** - Prevents unnecessary rebuilds
3. **Use keys wisely** - Helps Flutter identify widgets
4. **Avoid rebuilding** - Use `builder` patterns
5. **Profile performance** - Use Flutter DevTools

---

## Testing Widgets

### Widget Test Example

```dart
testWidgets('AppButton displays text', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AppButton(
          text: 'Click Me',
          onPressed: () {},
        ),
      ),
    ),
  );
  
  expect(find.text('Click Me'), findsOneWidget);
});
```

---

**Maintained by**: Frontend Team  
**Last Updated**: January 2026
