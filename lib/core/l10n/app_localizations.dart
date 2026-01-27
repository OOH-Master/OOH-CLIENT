import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AutoHome'**
  String get appTitle;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AutoHome'**
  String get appName;

  /// No description provided for @landingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Plan and manage OOH campaigns in one place'**
  String get landingHeadline;

  /// No description provided for @landingSubheadline.
  ///
  /// In en, this message translates to:
  /// **'Access thousands of billboards, citylights, and digital screens across the country.'**
  String get landingSubheadline;

  /// No description provided for @ctaDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover inventory'**
  String get ctaDiscover;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginTitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get nameLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'I am a...'**
  String get roleLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get hasAccount;

  /// No description provided for @discoverTab.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTab;

  /// No description provided for @mapTab.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// No description provided for @filterArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get filterArea;

  /// No description provided for @filterPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get filterPrice;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String results(Object count);

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for \"Location or Billboard\"'**
  String get searchPlaceholder;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @noInventoryFound.
  ///
  /// In en, this message translates to:
  /// **'No inventory found'**
  String get noInventoryFound;

  /// No description provided for @selectCityToViewInventory.
  ///
  /// In en, this message translates to:
  /// **'Select a city to view inventory'**
  String get selectCityToViewInventory;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @billboard.
  ///
  /// In en, this message translates to:
  /// **'Billboard'**
  String get billboard;

  /// No description provided for @digital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get digital;

  /// No description provided for @transit.
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get transit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// No description provided for @twoWeeks.
  ///
  /// In en, this message translates to:
  /// **'2 weeks'**
  String get twoWeeks;

  /// No description provided for @fourWeeks.
  ///
  /// In en, this message translates to:
  /// **'4 weeks'**
  String get fourWeeks;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @heroHeadlineQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you looking for media?'**
  String get heroHeadlineQuestion;

  /// No description provided for @heroSubheadlineShort.
  ///
  /// In en, this message translates to:
  /// **'Discover and filter available inventory in seconds.'**
  String get heroSubheadlineShort;

  /// No description provided for @searchLocationsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search locations...'**
  String get searchLocationsPlaceholder;

  /// No description provided for @seeMap.
  ///
  /// In en, this message translates to:
  /// **'See Map'**
  String get seeMap;

  /// No description provided for @scrollDown.
  ///
  /// In en, this message translates to:
  /// **'Scroll down'**
  String get scrollDown;

  /// No description provided for @heroKeywordBusStation.
  ///
  /// In en, this message translates to:
  /// **'Bus station'**
  String get heroKeywordBusStation;

  /// No description provided for @heroKeywordShoppingMall.
  ///
  /// In en, this message translates to:
  /// **'Shopping mall'**
  String get heroKeywordShoppingMall;

  /// No description provided for @heroKeywordMetro.
  ///
  /// In en, this message translates to:
  /// **'Metro'**
  String get heroKeywordMetro;

  /// No description provided for @heroKeywordAirport.
  ///
  /// In en, this message translates to:
  /// **'Airport'**
  String get heroKeywordAirport;

  /// No description provided for @heroKeywordDigitalBillboard.
  ///
  /// In en, this message translates to:
  /// **'Digital billboard'**
  String get heroKeywordDigitalBillboard;

  /// No description provided for @heroKeywordAnamorphic.
  ///
  /// In en, this message translates to:
  /// **'Anamorphic'**
  String get heroKeywordAnamorphic;

  /// No description provided for @heroKeywordWrapping.
  ///
  /// In en, this message translates to:
  /// **'Wrapping'**
  String get heroKeywordWrapping;

  /// No description provided for @heroKeywordElectronic.
  ///
  /// In en, this message translates to:
  /// **'Electronic'**
  String get heroKeywordElectronic;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get newHere;

  /// No description provided for @createAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccountLink;

  /// No description provided for @validatorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get validatorEmailRequired;

  /// No description provided for @validatorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validatorEmailInvalid;

  /// No description provided for @validatorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get validatorPasswordRequired;

  /// No description provided for @validatorPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validatorPasswordMin;

  /// No description provided for @validatorRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validatorRequired;

  /// No description provided for @viewLargerPhoto.
  ///
  /// In en, this message translates to:
  /// **'View larger photo'**
  String get viewLargerPhoto;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'see more'**
  String get seeMore;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'see less'**
  String get seeLess;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @startMediaInquiry.
  ///
  /// In en, this message translates to:
  /// **'Start a media inquiry'**
  String get startMediaInquiry;

  /// No description provided for @addToProposal.
  ///
  /// In en, this message translates to:
  /// **'Add your desired products to the proposal!'**
  String get addToProposal;

  /// No description provided for @howToUseMediaProducts.
  ///
  /// In en, this message translates to:
  /// **'How do I use media products?'**
  String get howToUseMediaProducts;

  /// No description provided for @howToUseMediaProductsDescription.
  ///
  /// In en, this message translates to:
  /// **'At AutoHome, you can quickly and easily create a proposal that includes products from the media you want.'**
  String get howToUseMediaProductsDescription;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @advertisingPeriod.
  ///
  /// In en, this message translates to:
  /// **'Advertising period'**
  String get advertisingPeriod;

  /// No description provided for @addProposal.
  ///
  /// In en, this message translates to:
  /// **'Add proposal'**
  String get addProposal;

  /// No description provided for @navSolutions.
  ///
  /// In en, this message translates to:
  /// **'Solutions'**
  String get navSolutions;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navResources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get navResources;

  /// No description provided for @navCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get navCompany;

  /// No description provided for @navLocations.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get navLocations;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @findMedia.
  ///
  /// In en, this message translates to:
  /// **'Find media'**
  String get findMedia;

  /// No description provided for @noAvailableBillboards.
  ///
  /// In en, this message translates to:
  /// **'No available billboards at the moment'**
  String get noAvailableBillboards;

  /// No description provided for @exploreBelgrade.
  ///
  /// In en, this message translates to:
  /// **'Explore Belgrade'**
  String get exploreBelgrade;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
