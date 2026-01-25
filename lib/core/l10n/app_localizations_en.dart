// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OOH Planner';

  @override
  String get landingHeadline => 'Plan and manage OOH campaigns in one place';

  @override
  String get landingSubheadline =>
      'Access thousands of billboards, citylights, and digital screens across the country.';

  @override
  String get ctaDiscover => 'Discover inventory';

  @override
  String get authLoginTitle => 'Log in';

  @override
  String get authRegisterTitle => 'Create account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get nameLabel => 'Full Name';

  @override
  String get roleLabel => 'I am a...';

  @override
  String get loginButton => 'Log in';

  @override
  String get registerButton => 'Register';

  @override
  String get noAccount => 'Don\'t have an account? Register';

  @override
  String get hasAccount => 'Already have an account? Log in';

  @override
  String get discoverTab => 'Discover';

  @override
  String get mapTab => 'Map';

  @override
  String get profileTab => 'Profile';

  @override
  String get filterType => 'Type';

  @override
  String get filterArea => 'Area';

  @override
  String get filterPrice => 'Price';

  @override
  String get logout => 'Log out';

  @override
  String get comingSoon => 'Coming Soon';
}
