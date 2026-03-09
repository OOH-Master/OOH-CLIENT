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

  /// No description provided for @filterUnitType.
  ///
  /// In en, this message translates to:
  /// **'Unit type'**
  String get filterUnitType;

  /// No description provided for @filterMediaFormat.
  ///
  /// In en, this message translates to:
  /// **'Media format'**
  String get filterMediaFormat;

  /// No description provided for @filterVenueType.
  ///
  /// In en, this message translates to:
  /// **'Venue type'**
  String get filterVenueType;

  /// No description provided for @filterEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get filterEnvironment;

  /// No description provided for @filterPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get filterPriceRange;

  /// No description provided for @filterMinPrice.
  ///
  /// In en, this message translates to:
  /// **'Min price'**
  String get filterMinPrice;

  /// No description provided for @filterMaxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max price'**
  String get filterMaxPrice;

  /// No description provided for @filterKeyword.
  ///
  /// In en, this message translates to:
  /// **'Search by keyword'**
  String get filterKeyword;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get applyFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get resetFilters;

  /// No description provided for @noResultsWithFilters.
  ///
  /// In en, this message translates to:
  /// **'No inventory found for the selected filters'**
  String get noResultsWithFilters;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @indoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get indoor;

  /// No description provided for @outdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get outdoor;

  /// No description provided for @roadside.
  ///
  /// In en, this message translates to:
  /// **'Roadside'**
  String get roadside;

  /// No description provided for @mall.
  ///
  /// In en, this message translates to:
  /// **'Mall'**
  String get mall;

  /// No description provided for @airport.
  ///
  /// In en, this message translates to:
  /// **'Airport'**
  String get airport;

  /// No description provided for @transitEnv.
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get transitEnv;

  /// No description provided for @illuminated.
  ///
  /// In en, this message translates to:
  /// **'Illuminated'**
  String get illuminated;

  /// No description provided for @frontlit.
  ///
  /// In en, this message translates to:
  /// **'Frontlit'**
  String get frontlit;

  /// No description provided for @backlit.
  ///
  /// In en, this message translates to:
  /// **'Backlit'**
  String get backlit;

  /// No description provided for @notIlluminated.
  ///
  /// In en, this message translates to:
  /// **'Not illuminated'**
  String get notIlluminated;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get selectAll;

  /// No description provided for @activeFiltersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String activeFiltersCount(Object count);

  /// No description provided for @dashboardTab.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTab;

  /// No description provided for @authGuardTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get authGuardTitle;

  /// No description provided for @authGuardMessage.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to continue.'**
  String get authGuardMessage;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String welcomeBack(Object name);

  /// No description provided for @totalInquiries.
  ///
  /// In en, this message translates to:
  /// **'Total Inquiries'**
  String get totalInquiries;

  /// No description provided for @activeInventory.
  ///
  /// In en, this message translates to:
  /// **'Active Inventory'**
  String get activeInventory;

  /// No description provided for @myInventory.
  ///
  /// In en, this message translates to:
  /// **'My Inventory'**
  String get myInventory;

  /// No description provided for @activeItems.
  ///
  /// In en, this message translates to:
  /// **'Active Items'**
  String get activeItems;

  /// No description provided for @myInquiries.
  ///
  /// In en, this message translates to:
  /// **'My Inquiries'**
  String get myInquiries;

  /// No description provided for @myCampaigns.
  ///
  /// In en, this message translates to:
  /// **'My Campaigns'**
  String get myCampaigns;

  /// No description provided for @myBrands.
  ///
  /// In en, this message translates to:
  /// **'My Brands'**
  String get myBrands;

  /// No description provided for @allInquiries.
  ///
  /// In en, this message translates to:
  /// **'All Inquiries'**
  String get allInquiries;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// No description provided for @addInventory.
  ///
  /// In en, this message translates to:
  /// **'Add Inventory'**
  String get addInventory;

  /// No description provided for @browseInventory.
  ///
  /// In en, this message translates to:
  /// **'Browse Inventory'**
  String get browseInventory;

  /// No description provided for @newCampaign.
  ///
  /// In en, this message translates to:
  /// **'New Campaign'**
  String get newCampaign;

  /// No description provided for @recentInquiries.
  ///
  /// In en, this message translates to:
  /// **'Recent Inquiries'**
  String get recentInquiries;

  /// No description provided for @recentInventory.
  ///
  /// In en, this message translates to:
  /// **'Recent Inventory'**
  String get recentInventory;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereYet;

  /// No description provided for @inquiries.
  ///
  /// In en, this message translates to:
  /// **'Inquiries'**
  String get inquiries;

  /// No description provided for @inquiryDetail.
  ///
  /// In en, this message translates to:
  /// **'Inquiry Detail'**
  String get inquiryDetail;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact Email'**
  String get contactEmail;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contactPhone;

  /// No description provided for @campaignBrief.
  ///
  /// In en, this message translates to:
  /// **'Campaign Brief'**
  String get campaignBrief;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @adminNotes.
  ///
  /// In en, this message translates to:
  /// **'Admin Notes'**
  String get adminNotes;

  /// No description provided for @saveNotes.
  ///
  /// In en, this message translates to:
  /// **'Save Notes'**
  String get saveNotes;

  /// No description provided for @quotedPrice.
  ///
  /// In en, this message translates to:
  /// **'Quoted Price'**
  String get quotedPrice;

  /// No description provided for @updatePrice.
  ///
  /// In en, this message translates to:
  /// **'Update Price'**
  String get updatePrice;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @noInquiries.
  ///
  /// In en, this message translates to:
  /// **'No inquiries yet'**
  String get noInquiries;

  /// No description provided for @inquiryCreated.
  ///
  /// In en, this message translates to:
  /// **'Inquiry submitted successfully'**
  String get inquiryCreated;

  /// No description provided for @newInquiry.
  ///
  /// In en, this message translates to:
  /// **'New Inquiry'**
  String get newInquiry;

  /// No description provided for @submitInquiry.
  ///
  /// In en, this message translates to:
  /// **'Submit Inquiry'**
  String get submitInquiry;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @campaignDetails.
  ///
  /// In en, this message translates to:
  /// **'Campaign Details'**
  String get campaignDetails;

  /// No description provided for @selectedUnits.
  ///
  /// In en, this message translates to:
  /// **'Selected Units'**
  String get selectedUnits;

  /// No description provided for @notesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Notes updated'**
  String get notesUpdated;

  /// No description provided for @priceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Price updated'**
  String get priceUpdated;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusPricingReady.
  ///
  /// In en, this message translates to:
  /// **'Pricing Ready'**
  String get statusPricingReady;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusRealized.
  ///
  /// In en, this message translates to:
  /// **'Realized'**
  String get statusRealized;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @inventoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Inventory Management'**
  String get inventoryManagement;

  /// No description provided for @createInventory.
  ///
  /// In en, this message translates to:
  /// **'Create Inventory'**
  String get createInventory;

  /// No description provided for @editInventory.
  ///
  /// In en, this message translates to:
  /// **'Edit Inventory'**
  String get editInventory;

  /// No description provided for @deleteInventory.
  ///
  /// In en, this message translates to:
  /// **'Delete Inventory'**
  String get deleteInventory;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @siteName.
  ///
  /// In en, this message translates to:
  /// **'Site Name'**
  String get siteName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @unitType.
  ///
  /// In en, this message translates to:
  /// **'Unit Type'**
  String get unitType;

  /// No description provided for @mediaFormat.
  ///
  /// In en, this message translates to:
  /// **'Media Format'**
  String get mediaFormat;

  /// No description provided for @venueType.
  ///
  /// In en, this message translates to:
  /// **'Venue Type'**
  String get venueType;

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// No description provided for @illumination.
  ///
  /// In en, this message translates to:
  /// **'Illumination'**
  String get illumination;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @cycleType.
  ///
  /// In en, this message translates to:
  /// **'Billing Cycle'**
  String get cycleType;

  /// No description provided for @inventoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Inventory item created'**
  String get inventoryCreated;

  /// No description provided for @inventoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Inventory item updated'**
  String get inventoryUpdated;

  /// No description provided for @inventoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Inventory item deleted'**
  String get inventoryDeleted;

  /// No description provided for @noInventoryItems.
  ///
  /// In en, this message translates to:
  /// **'No inventory items'**
  String get noInventoryItems;

  /// No description provided for @campaigns.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get campaigns;

  /// No description provided for @campaignDetail.
  ///
  /// In en, this message translates to:
  /// **'Campaign Detail'**
  String get campaignDetail;

  /// No description provided for @createCampaign.
  ///
  /// In en, this message translates to:
  /// **'Create Campaign'**
  String get createCampaign;

  /// No description provided for @campaignName.
  ///
  /// In en, this message translates to:
  /// **'Campaign Name'**
  String get campaignName;

  /// No description provided for @campaignDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get campaignDescription;

  /// No description provided for @campaignBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get campaignBudget;

  /// No description provided for @brandUsername.
  ///
  /// In en, this message translates to:
  /// **'Brand (username)'**
  String get brandUsername;

  /// No description provided for @noCampaigns.
  ///
  /// In en, this message translates to:
  /// **'No campaigns yet'**
  String get noCampaigns;

  /// No description provided for @campaignCreated.
  ///
  /// In en, this message translates to:
  /// **'Campaign created'**
  String get campaignCreated;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusInNegotiation.
  ///
  /// In en, this message translates to:
  /// **'In Negotiation'**
  String get statusInNegotiation;

  /// No description provided for @statusBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get statusBooked;

  /// No description provided for @statusRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get statusRunning;

  /// No description provided for @statusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get statusFinished;

  /// No description provided for @configManagement.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configManagement;

  /// No description provided for @countries.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get countries;

  /// No description provided for @cities.
  ///
  /// In en, this message translates to:
  /// **'Cities'**
  String get cities;

  /// No description provided for @unitTypes.
  ///
  /// In en, this message translates to:
  /// **'Unit Types'**
  String get unitTypes;

  /// No description provided for @mediaFormats.
  ///
  /// In en, this message translates to:
  /// **'Media Formats'**
  String get mediaFormats;

  /// No description provided for @venueTypes.
  ///
  /// In en, this message translates to:
  /// **'Venue Types'**
  String get venueTypes;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// No description provided for @allCountries.
  ///
  /// In en, this message translates to:
  /// **'All Countries'**
  String get allCountries;

  /// No description provided for @allCities.
  ///
  /// In en, this message translates to:
  /// **'All Cities'**
  String get allCities;

  /// No description provided for @configCreated.
  ///
  /// In en, this message translates to:
  /// **'Item created successfully'**
  String get configCreated;

  /// No description provided for @brands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get brands;

  /// No description provided for @addBrand.
  ///
  /// In en, this message translates to:
  /// **'Add Brand'**
  String get addBrand;

  /// No description provided for @brandName.
  ///
  /// In en, this message translates to:
  /// **'Brand Name'**
  String get brandName;

  /// No description provided for @brandCreated.
  ///
  /// In en, this message translates to:
  /// **'Brand created'**
  String get brandCreated;

  /// No description provided for @noBrands.
  ///
  /// In en, this message translates to:
  /// **'No brands yet'**
  String get noBrands;
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
