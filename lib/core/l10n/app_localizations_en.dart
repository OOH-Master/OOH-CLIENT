// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AutoHome';

  @override
  String get appName => 'AutoHome';

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

  @override
  String results(Object count) {
    return '$count results';
  }

  @override
  String get selectCity => 'Select City';

  @override
  String get searchPlaceholder => 'Search for \"Location or Billboard\"';

  @override
  String get allCategories => 'All Categories';

  @override
  String get filters => 'Filters';

  @override
  String get view => 'View';

  @override
  String get available => 'Available';

  @override
  String get booked => 'Booked';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get noInventoryFound => 'No inventory found';

  @override
  String get selectCityToViewInventory => 'Select a city to view inventory';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get billboard => 'Billboard';

  @override
  String get digital => 'Digital';

  @override
  String get transit => 'Transit';

  @override
  String get search => 'Search...';

  @override
  String get day => 'day';

  @override
  String get week => 'week';

  @override
  String get twoWeeks => '2 weeks';

  @override
  String get fourWeeks => '4 weeks';

  @override
  String get month => 'month';

  @override
  String get heroHeadlineQuestion => 'Are you looking for media?';

  @override
  String get heroSubheadlineShort =>
      'Discover and filter available inventory in seconds.';

  @override
  String get searchLocationsPlaceholder => 'Search locations...';

  @override
  String get seeMap => 'See Map';

  @override
  String get scrollDown => 'Scroll down';

  @override
  String get heroKeywordBusStation => 'Bus station';

  @override
  String get heroKeywordShoppingMall => 'Shopping mall';

  @override
  String get heroKeywordMetro => 'Metro';

  @override
  String get heroKeywordAirport => 'Airport';

  @override
  String get heroKeywordDigitalBillboard => 'Digital billboard';

  @override
  String get heroKeywordAnamorphic => 'Anamorphic';

  @override
  String get heroKeywordWrapping => 'Wrapping';

  @override
  String get heroKeywordElectronic => 'Electronic';

  @override
  String get newHere => 'New here?';

  @override
  String get createAccountLink => 'Create an account';

  @override
  String get validatorEmailRequired => 'Please enter your email';

  @override
  String get validatorEmailInvalid => 'Please enter a valid email';

  @override
  String get validatorPasswordRequired => 'Please enter your password';

  @override
  String get validatorPasswordMin => 'Password must be at least 6 characters';

  @override
  String get validatorRequired => 'Required';

  @override
  String get viewLargerPhoto => 'View larger photo';

  @override
  String get seeMore => 'see more';

  @override
  String get seeLess => 'see less';

  @override
  String get updated => 'Updated';

  @override
  String get share => 'Share';

  @override
  String get startMediaInquiry => 'Start a media inquiry';

  @override
  String get addToProposal => 'Add your desired products to the proposal!';

  @override
  String get howToUseMediaProducts => 'How do I use media products?';

  @override
  String get howToUseMediaProductsDescription =>
      'At AutoHome, you can quickly and easily create a proposal that includes products from the media you want.';

  @override
  String get viewDetails => 'View Details';

  @override
  String get perMonth => 'per month';

  @override
  String get individual => 'Individual';

  @override
  String get advertisingPeriod => 'Advertising period';

  @override
  String get addProposal => 'Add proposal';

  @override
  String get navSolutions => 'Solutions';

  @override
  String get navProducts => 'Products';

  @override
  String get navResources => 'Resources';

  @override
  String get navCompany => 'Company';

  @override
  String get navLocations => 'Locations';

  @override
  String get getStarted => 'Get started';

  @override
  String get menu => 'Menu';

  @override
  String get home => 'Home';

  @override
  String get findMedia => 'Find media';

  @override
  String get noAvailableBillboards => 'No available billboards at the moment';

  @override
  String get exploreBelgrade => 'Explore Belgrade';

  @override
  String get filterUnitType => 'Unit type';

  @override
  String get filterMediaFormat => 'Media format';

  @override
  String get filterVenueType => 'Venue type';

  @override
  String get filterEnvironment => 'Environment';

  @override
  String get filterPriceRange => 'Price range';

  @override
  String get filterMinPrice => 'Min price';

  @override
  String get filterMaxPrice => 'Max price';

  @override
  String get filterKeyword => 'Search by keyword';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String get noResultsWithFilters =>
      'No inventory found for the selected filters';

  @override
  String get usernameLabel => 'Username';

  @override
  String get indoor => 'Indoor';

  @override
  String get outdoor => 'Outdoor';

  @override
  String get roadside => 'Roadside';

  @override
  String get mall => 'Mall';

  @override
  String get airport => 'Airport';

  @override
  String get transitEnv => 'Transit';

  @override
  String get illuminated => 'Illuminated';

  @override
  String get frontlit => 'Frontlit';

  @override
  String get backlit => 'Backlit';

  @override
  String get notIlluminated => 'Not illuminated';

  @override
  String get selectAll => 'All';

  @override
  String activeFiltersCount(Object count) {
    return '$count active';
  }

  @override
  String get dashboardTab => 'Dashboard';

  @override
  String get authGuardTitle => 'Sign in required';

  @override
  String get authGuardMessage => 'You must be signed in to continue.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String welcomeBack(Object name) {
    return 'Welcome back, $name';
  }

  @override
  String get totalInquiries => 'Total Inquiries';

  @override
  String get activeInventory => 'Active Inventory';

  @override
  String get myInventory => 'My Inventory';

  @override
  String get activeItems => 'Active Items';

  @override
  String get myInquiries => 'My Inquiries';

  @override
  String get myCampaigns => 'My Campaigns';

  @override
  String get myBrands => 'My Brands';

  @override
  String get allInquiries => 'All Inquiries';

  @override
  String get configuration => 'Configuration';

  @override
  String get addInventory => 'Add Inventory';

  @override
  String get browseInventory => 'Browse Inventory';

  @override
  String get newCampaign => 'New Campaign';

  @override
  String get recentInquiries => 'Recent Inquiries';

  @override
  String get recentInventory => 'Recent Inventory';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get nothingHereYet => 'Nothing here yet';

  @override
  String get inquiries => 'Inquiries';

  @override
  String get inquiryDetail => 'Inquiry Detail';

  @override
  String get contactName => 'Contact Name';

  @override
  String get contactEmail => 'Contact Email';

  @override
  String get contactPhone => 'Contact Phone';

  @override
  String get campaignBrief => 'Campaign Brief';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get budget => 'Budget';

  @override
  String get status => 'Status';

  @override
  String get items => 'Items';

  @override
  String get adminNotes => 'Admin Notes';

  @override
  String get saveNotes => 'Save Notes';

  @override
  String get quotedPrice => 'Quoted Price';

  @override
  String get updatePrice => 'Update Price';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get noInquiries => 'No inquiries yet';

  @override
  String get inquiryCreated => 'Inquiry submitted successfully';

  @override
  String get notesUpdated => 'Notes updated';

  @override
  String get priceUpdated => 'Price updated';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusPricingReady => 'Pricing Ready';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusRealized => 'Realized';

  @override
  String get statusClosed => 'Closed';

  @override
  String get inventoryManagement => 'Inventory Management';

  @override
  String get createInventory => 'Create Inventory';

  @override
  String get editInventory => 'Edit Inventory';

  @override
  String get deleteInventory => 'Delete Inventory';

  @override
  String get deleteConfirmation => 'Are you sure you want to delete this item?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get siteName => 'Site Name';

  @override
  String get description => 'Description';

  @override
  String get address => 'Address';

  @override
  String get country => 'Country';

  @override
  String get city => 'City';

  @override
  String get unitType => 'Unit Type';

  @override
  String get mediaFormat => 'Media Format';

  @override
  String get venueType => 'Venue Type';

  @override
  String get environment => 'Environment';

  @override
  String get illumination => 'Illumination';

  @override
  String get price => 'Price';

  @override
  String get currency => 'Currency';

  @override
  String get cycleType => 'Billing Cycle';

  @override
  String get inventoryCreated => 'Inventory item created';

  @override
  String get inventoryUpdated => 'Inventory item updated';

  @override
  String get inventoryDeleted => 'Inventory item deleted';

  @override
  String get noInventoryItems => 'No inventory items';

  @override
  String get campaigns => 'Campaigns';

  @override
  String get campaignDetail => 'Campaign Detail';

  @override
  String get createCampaign => 'Create Campaign';

  @override
  String get campaignName => 'Campaign Name';

  @override
  String get campaignDescription => 'Description';

  @override
  String get campaignBudget => 'Budget';

  @override
  String get brandUsername => 'Brand (username)';

  @override
  String get noCampaigns => 'No campaigns yet';

  @override
  String get campaignCreated => 'Campaign created';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusInNegotiation => 'In Negotiation';

  @override
  String get statusBooked => 'Booked';

  @override
  String get statusRunning => 'Running';

  @override
  String get statusFinished => 'Finished';

  @override
  String get configManagement => 'Configuration';

  @override
  String get countries => 'Countries';

  @override
  String get cities => 'Cities';

  @override
  String get unitTypes => 'Unit Types';

  @override
  String get mediaFormats => 'Media Formats';

  @override
  String get venueTypes => 'Venue Types';

  @override
  String get addNew => 'Add New';

  @override
  String get enterName => 'Enter name';

  @override
  String get selectCountry => 'Select Country';

  @override
  String get configCreated => 'Item created successfully';

  @override
  String get brands => 'Brands';

  @override
  String get addBrand => 'Add Brand';

  @override
  String get brandName => 'Brand Name';

  @override
  String get brandCreated => 'Brand created';

  @override
  String get noBrands => 'No brands yet';
}
