import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('pl'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Vamos Ride Sharing'**
  String get appTitle;

  /// Generic retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Snackbar message for not-yet-implemented features
  ///
  /// In en, this message translates to:
  /// **'{feature} coming soon!'**
  String comingSoon(String feature);

  /// Divider label between login methods
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// Validation message for empty required fields
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Bottom navigation label for Rides tab
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get navRides;

  /// Bottom navigation label for Packages tab
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get navPackages;

  /// Bottom navigation label for Profile tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Bottom navigation label for Messages tab
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// Login screen title and button label
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// Email text field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Password text field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Validation message for empty email
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// Validation message for invalid email format
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// Validation message for empty password
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Google sign-in button label
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Text before the sign-up link on login screen
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Link label to navigate to registration
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// Registration screen title and button label
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// Display name text field label
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayNameLabel;

  /// Helper text below display name field
  ///
  /// In en, this message translates to:
  /// **'This is the name other users will see.'**
  String get displayNameHelper;

  /// Validation message for empty display name
  ///
  /// In en, this message translates to:
  /// **'Enter a display name'**
  String get enterDisplayName;

  /// Validation message for short display name
  ///
  /// In en, this message translates to:
  /// **'Display name must be at least 2 characters'**
  String get displayNameMinLength;

  /// Confirm password text field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// Validation message for empty confirm password
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPassword;

  /// Validation message when passwords differ
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Validation message for empty password on registration
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get enterAPassword;

  /// Validation message for short password
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Text before login link on registration screen
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Snackbar shown when Google sign-up tapped
  ///
  /// In en, this message translates to:
  /// **'Google sign-up coming soon!'**
  String get googleSignUpComingSoon;

  /// Accessibility label for the hero search card
  ///
  /// In en, this message translates to:
  /// **'Search for rides. {label}'**
  String searchSemanticLabel(String label);

  /// Tooltip for the swap button on search card
  ///
  /// In en, this message translates to:
  /// **'Swap origin and destination'**
  String get swapOriginDestination;

  /// Default empty search label
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get whereToSearch;

  /// Search label showing origin city only
  ///
  /// In en, this message translates to:
  /// **'From {city}'**
  String searchFromCity(String city);

  /// Search label showing destination city only
  ///
  /// In en, this message translates to:
  /// **'To {city}'**
  String searchToCity(String city);

  /// Search label showing full route (origin to destination)
  ///
  /// In en, this message translates to:
  /// **'{origin} → {destination}'**
  String searchRoute(String origin, String destination);

  /// Button label to view user's own rides
  ///
  /// In en, this message translates to:
  /// **'My Rides'**
  String get myRides;

  /// Button label to open the publish selection sheet
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// Title of the publish selection bottom sheet
  ///
  /// In en, this message translates to:
  /// **'What are you posting?'**
  String get whatAreYouPosting;

  /// Option to post a ride as driver
  ///
  /// In en, this message translates to:
  /// **'Offer a Ride'**
  String get offerARide;

  /// Subtitle for the offer-a-ride option
  ///
  /// In en, this message translates to:
  /// **'I\'m driving and have empty seats.'**
  String get offerARideSubtitle;

  /// Option to post a seat request as passenger
  ///
  /// In en, this message translates to:
  /// **'Request a Ride'**
  String get requestARide;

  /// Subtitle for the request-a-ride option
  ///
  /// In en, this message translates to:
  /// **'I need a driver for a specific date.'**
  String get requestARideSubtitle;

  /// Label for current date in the date strip
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Label for next day in the date strip
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Tooltip for the left arrow in the date strip
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// Tooltip for the right arrow in the date strip
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// Time of day label: 05:00–11:59
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get partOfDayMorning;

  /// Time of day label: 12:00–16:59
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get partOfDayAfternoon;

  /// Time of day label: 17:00–21:59
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get partOfDayEvening;

  /// Time of day label: 22:00–04:59
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get partOfDayNight;

  /// Shown when departure time is undefined
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get anyTime;

  /// Shown when departure time is approximate / budget is unset
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get flexible;

  /// Shown when time info should be asked from driver
  ///
  /// In en, this message translates to:
  /// **'Ask driver'**
  String get askDriver;

  /// Shown on ride card when price is unknown
  ///
  /// In en, this message translates to:
  /// **'Ask about price'**
  String get askAboutPrice;

  /// Shown when time info should be asked from passenger
  ///
  /// In en, this message translates to:
  /// **'Ask passenger'**
  String get askPassenger;

  /// Formatted departure date on offer cards and details
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String offerDate(DateTime date);

  /// Formatted date in the date strip selector
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String dateStripDate(DateTime date);

  /// Price display with PLN currency
  ///
  /// In en, this message translates to:
  /// **'{price} PLN'**
  String formattedPrice(int price);

  /// Shown on offer card when price is not set
  ///
  /// In en, this message translates to:
  /// **'? PLN'**
  String get unknownPrice;

  /// Number of available seats on a ride offer
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 seat} other{{count} seats}}'**
  String seatCount(int count);

  /// Number of passengers needed for a seat request
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 passenger} other{{count} passengers}}'**
  String passengerCount(int count);

  /// Number of completed rides shown in user ratings
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 ride} other{{count} rides}}'**
  String rideCount(int count);

  /// Label for the price field on ride offers
  ///
  /// In en, this message translates to:
  /// **'Price per seat'**
  String get pricePerSeat;

  /// Label for the seat count field on ride offers
  ///
  /// In en, this message translates to:
  /// **'Available seats'**
  String get availableSeats;

  /// Label for the budget field on seat requests
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// Label for the passenger count on seat requests
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengers;

  /// Form field label for number of passengers
  ///
  /// In en, this message translates to:
  /// **'Passengers Needed'**
  String get passengersNeeded;

  /// Badge text for internal (verified) source offers
  ///
  /// In en, this message translates to:
  /// **'Verified member'**
  String get verifiedMember;

  /// Badge text for external (Facebook) source offers
  ///
  /// In en, this message translates to:
  /// **'Community listing'**
  String get communityListing;

  /// Chip label indicating offer comes from Facebook
  ///
  /// In en, this message translates to:
  /// **'Source: Facebook'**
  String get sourceFacebook;

  /// Contact method label for phone calls
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callLabel;

  /// Contact method label for Facebook links
  ///
  /// In en, this message translates to:
  /// **'Open Facebook post'**
  String get openFacebookPost;

  /// Contact method label for email
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get sendEmail;

  /// Contact method label for sending an SMS
  ///
  /// In en, this message translates to:
  /// **'Send SMS'**
  String get sendSmsLabel;

  /// Error when a URL cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get couldNotOpenLink;

  /// Error when the phone dialer cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open dialer'**
  String get couldNotOpenDialer;

  /// Error when the SMS app cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open messaging app'**
  String get couldNotOpenMessagingApp;

  /// Error when the email client cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open email client'**
  String get couldNotOpenEmailClient;

  /// Screen title for viewing a ride offer
  ///
  /// In en, this message translates to:
  /// **'Ride Details'**
  String get rideDetails;

  /// Screen title for viewing a seat request
  ///
  /// In en, this message translates to:
  /// **'Ride Request'**
  String get rideRequest;

  /// Role label shown on ride offer details
  ///
  /// In en, this message translates to:
  /// **'Offering a ride'**
  String get offeringARide;

  /// Role label shown on seat request details
  ///
  /// In en, this message translates to:
  /// **'Looking for a ride'**
  String get lookingForARide;

  /// Button label to contact a user
  ///
  /// In en, this message translates to:
  /// **'Contact {name}'**
  String contactUser(String name);

  /// Fallback subtitle for external source users
  ///
  /// In en, this message translates to:
  /// **'Facebook User'**
  String get facebookUser;

  /// Section label for price on offer details
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// Section label for availability on offer details
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availabilityLabel;

  /// Section title for driver info on ride offers
  ///
  /// In en, this message translates to:
  /// **'DRIVER'**
  String get driverLabel;

  /// Section title for passenger info on seat requests
  ///
  /// In en, this message translates to:
  /// **'PASSENGER'**
  String get passengerLabel;

  /// Fallback display name when driver name is missing
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverFallbackName;

  /// Fallback display name when passenger name is missing
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get passengerFallbackName;

  /// Rating with ride count displayed next to user name
  ///
  /// In en, this message translates to:
  /// **'{rating} ({count})'**
  String ratingDisplay(String rating, int count);

  /// Ride status chip label: accepting passengers
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// Ride status chip label: no seats left
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get statusFull;

  /// Ride status chip label: ride finished
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Status chip label: ride or seat cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// Seat status chip label: looking for a driver
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get statusSearching;

  /// Seat status chip label: driver found
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get statusBooked;

  /// Seat status chip label: request expired
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// Seat status chip label: user banned
  ///
  /// In en, this message translates to:
  /// **'Banned'**
  String get statusBanned;

  /// Empty state for rides search results
  ///
  /// In en, this message translates to:
  /// **'No rides found matching your criteria.'**
  String get noRidesFound;

  /// Empty state for seats search results
  ///
  /// In en, this message translates to:
  /// **'No passenger requests found matching your criteria.'**
  String get noPassengerRequests;

  /// Screen title for user's own offers
  ///
  /// In en, this message translates to:
  /// **'My Offers'**
  String get myOffers;

  /// Segmented button label: show all offer types
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Segmented button label: show only ride offers
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get filterRides;

  /// Segmented button label: show only seat requests
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get filterPassengers;

  /// Error message when offers fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load offers'**
  String get failedToLoadOffers;

  /// Empty state when user has no offers
  ///
  /// In en, this message translates to:
  /// **'No offers yet'**
  String get noOffersYet;

  /// AppBar title for ride creation screen
  ///
  /// In en, this message translates to:
  /// **'Post Your Ride'**
  String get postYourRide;

  /// Header text on ride creation form
  ///
  /// In en, this message translates to:
  /// **'Offer a Ride'**
  String get offerARideHeader;

  /// Text field label for departure city
  ///
  /// In en, this message translates to:
  /// **'Origin City'**
  String get originCityLabel;

  /// Text field label for arrival city
  ///
  /// In en, this message translates to:
  /// **'Destination City'**
  String get destinationCityLabel;

  /// Validation message for empty origin
  ///
  /// In en, this message translates to:
  /// **'Origin City is required'**
  String get originRequired;

  /// Validation message for empty destination
  ///
  /// In en, this message translates to:
  /// **'Destination City is required'**
  String get destinationRequired;

  /// Validation message when origin not picked from autocomplete
  ///
  /// In en, this message translates to:
  /// **'Select origin from suggestions'**
  String get selectOriginFromSuggestions;

  /// Validation message when destination not picked from autocomplete
  ///
  /// In en, this message translates to:
  /// **'Select destination from suggestions'**
  String get selectDestinationFromSuggestions;

  /// Validation message when destination equals origin
  ///
  /// In en, this message translates to:
  /// **'Must differ from origin'**
  String get mustDifferFromOrigin;

  /// Form field label for departure date
  ///
  /// In en, this message translates to:
  /// **'Date of Departure'**
  String get dateOfDeparture;

  /// Validation message for empty departure date
  ///
  /// In en, this message translates to:
  /// **'Select departure date'**
  String get selectDepartureDate;

  /// Label for the part-of-day selector
  ///
  /// In en, this message translates to:
  /// **'Time of Day'**
  String get timeOfDay;

  /// Form field label for departure time
  ///
  /// In en, this message translates to:
  /// **'Time of Departure'**
  String get timeOfDeparture;

  /// Validation message for empty departure time
  ///
  /// In en, this message translates to:
  /// **'Select departure time'**
  String get selectDepartureTime;

  /// Form field label for number of seats
  ///
  /// In en, this message translates to:
  /// **'Available Seats'**
  String get availableSeatsLabel;

  /// Validation message for seat count out of range
  ///
  /// In en, this message translates to:
  /// **'1-8 seats allowed'**
  String get seatsRange;

  /// Form field label for price input
  ///
  /// In en, this message translates to:
  /// **'Price per Seat'**
  String get pricePerSeatLabel;

  /// Validation message for price out of range
  ///
  /// In en, this message translates to:
  /// **'1-999 PLN'**
  String get priceRange;

  /// Form field label for ride description
  ///
  /// In en, this message translates to:
  /// **'Ride Description (Optional)'**
  String get rideDescriptionOptional;

  /// Validation message for text exceeding character limit
  ///
  /// In en, this message translates to:
  /// **'Max {count} characters'**
  String maxCharacters(int count);

  /// Submit button label for ride creation
  ///
  /// In en, this message translates to:
  /// **'Post Ride'**
  String get postRide;

  /// AppBar title and submit button for seat request creation
  ///
  /// In en, this message translates to:
  /// **'Post Seat Request'**
  String get postSeatRequest;

  /// Header text on seat request creation form
  ///
  /// In en, this message translates to:
  /// **'Find a Ride'**
  String get findARideHeader;

  /// Validation message for passenger count out of range
  ///
  /// In en, this message translates to:
  /// **'1-8 passengers allowed'**
  String get passengersRange;

  /// Form field label for budget input
  ///
  /// In en, this message translates to:
  /// **'Budget (Optional)'**
  String get budgetOptional;

  /// Form field label for seat request description
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// Snackbar message after successful seat request creation
  ///
  /// In en, this message translates to:
  /// **'Seat request created successfully!'**
  String get seatRequestCreated;

  /// Profile screen and AppBar title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Message shown to unauthenticated users on profile tab
  ///
  /// In en, this message translates to:
  /// **'Log in to see your profile'**
  String get logInToSeeProfile;

  /// Button to navigate to login from profile tab
  ///
  /// In en, this message translates to:
  /// **'Log In / Sign Up'**
  String get logInSignUp;

  /// Section title for verification badges
  ///
  /// In en, this message translates to:
  /// **'Trust & Verification'**
  String get trustAndVerification;

  /// Feature name for the coming-soon email verification
  ///
  /// In en, this message translates to:
  /// **'Email verification'**
  String get emailVerification;

  /// Feature name for the coming-soon phone verification
  ///
  /// In en, this message translates to:
  /// **'Phone verification'**
  String get phoneVerification;

  /// Verification badge and form label for phone
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// Section title for user stats
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Stats card label for rides as driver
  ///
  /// In en, this message translates to:
  /// **'Rides Given'**
  String get ridesGiven;

  /// Stats card label for rides as passenger
  ///
  /// In en, this message translates to:
  /// **'Rides Taken'**
  String get ridesTaken;

  /// Stats card label for user rating
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Action tile title and AppBar title for edit profile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Subtitle for edit profile action tile
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get updatePersonalInfo;

  /// Subtitle for my rides action tile
  ///
  /// In en, this message translates to:
  /// **'View your ride history'**
  String get viewRideHistory;

  /// Logout button label
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Form field label for phone number
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// Hint text for phone number field
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number (optional)'**
  String get phoneHint;

  /// Form field label for bio
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// Hint text for bio field
  ///
  /// In en, this message translates to:
  /// **'Tell others about yourself (optional)'**
  String get bioHint;

  /// Validation message for empty display name on edit
  ///
  /// In en, this message translates to:
  /// **'Display name is required'**
  String get displayNameRequired;

  /// Submit button for profile edit form
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Snackbar after successful profile update
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// Snackbar prefix when profile update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// Card title for profile completion tracker
  ///
  /// In en, this message translates to:
  /// **'Profile Completeness'**
  String get profileCompleteness;

  /// Shown when profile is 100% complete
  ///
  /// In en, this message translates to:
  /// **'Profile complete!'**
  String get profileComplete;

  /// Profile completion percentage label
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String percentComplete(int percent);

  /// Button to navigate to edit profile to complete it
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Title when public profile cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Profile not available'**
  String get profileNotAvailable;

  /// Message when public profile cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'This profile cannot be displayed right now.'**
  String get profileNotAvailableMessage;

  /// Section title for bio on public profile
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Placeholder when user has no bio
  ///
  /// In en, this message translates to:
  /// **'No bio added yet.'**
  String get noBioYet;

  /// Stats label for ride count on public profile
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get rides;

  /// Stats label for review count on public profile
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// Section title and fallback name for vehicle on public profile
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// Screen title for bookings list
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// Title for bookings placeholder screen
  ///
  /// In en, this message translates to:
  /// **'Bookings Coming Soon'**
  String get bookingsComingSoon;

  /// Message for bookings placeholder screen
  ///
  /// In en, this message translates to:
  /// **'The booking feature is being redesigned. Check back later!'**
  String get bookingsComingSoonMessage;

  /// Messages tab header
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// Chat screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// Error message when messages fail to load
  ///
  /// In en, this message translates to:
  /// **'Could not load messages'**
  String get couldNotLoadMessages;

  /// Empty state title for messages
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// Empty state subtitle for messages tab
  ///
  /// In en, this message translates to:
  /// **'Start a conversation from a ride listing'**
  String get startConversation;

  /// Empty state in a new chat conversation
  ///
  /// In en, this message translates to:
  /// **'Send a message to start the conversation'**
  String get sendMessageToStart;

  /// Hint text in chat message input field
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// Time-ago label for messages less than 1 minute old
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get timeNow;

  /// Abbreviated time-ago label for minutes
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String timeMinutesAgo(int count);

  /// Abbreviated time-ago label for hours
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String timeHoursAgo(int count);

  /// Abbreviated time-ago label for days
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String timeDaysAgo(int count);

  /// Packages tab title
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get packagesTitle;

  /// Placeholder subtitle for packages tab
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get packagesComingSoon;

  /// Error screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// Title when navigating to a non-existent route
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// Message when navigating to a non-existent route
  ///
  /// In en, this message translates to:
  /// **'The page you are looking for does not exist.'**
  String get pageNotFoundMessage;

  /// Button to return to the home screen from error
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// Section title for language settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language option: follow device locale
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// Language option: force English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language option: force Polish
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get languagePolish;

  /// Subtitle under System option showing the resolved language
  ///
  /// In en, this message translates to:
  /// **'Currently using: {language}'**
  String effectiveLanguage(String language);

  /// Search button label when in rides mode
  ///
  /// In en, this message translates to:
  /// **'Search Rides'**
  String get searchRides;

  /// Search button label when in passengers mode
  ///
  /// In en, this message translates to:
  /// **'Search Passengers'**
  String get searchPassengers;

  /// Short label for origin city in search sheet
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// Short label for destination city in search sheet
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// Short label for departure date in search sheet
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// Shown when no departure date is selected
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get anyDate;

  /// Tooltip for clearing the selected date
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get clearDate;

  /// Button label to reset all search fields
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Placeholder when no city is selected in route picker
  ///
  /// In en, this message translates to:
  /// **'Choose city'**
  String get chooseCity;

  /// Label for city autocomplete field in picker sheet
  ///
  /// In en, this message translates to:
  /// **'Search city'**
  String get searchCity;

  /// Empty search label on the compact search summary bar
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get whereAreYouGoing;

  /// Nudge card copy when both origin and destination are set
  ///
  /// In en, this message translates to:
  /// **'Need a different time for {origin} → {destination}?'**
  String nudgeRouteTime(String origin, String destination);

  /// Nudge card copy when only date is set
  ///
  /// In en, this message translates to:
  /// **'Nothing on {date}? Post your own request.'**
  String nudgeDateFallback(String date);

  /// Nudge card copy when no search criteria are set
  ///
  /// In en, this message translates to:
  /// **'Not finding what you need? Post a request and let drivers come to you.'**
  String get nudgeGeneric;

  /// Link label on nudge card
  ///
  /// In en, this message translates to:
  /// **'Post a request'**
  String get postARequest;

  /// Button label on zero results funnel
  ///
  /// In en, this message translates to:
  /// **'Post Request'**
  String get postRequest;

  /// Short empty state label in zero results funnel
  ///
  /// In en, this message translates to:
  /// **'No rides found'**
  String get noRidesFoundShort;

  /// Headline in the zero results funnel card
  ///
  /// In en, this message translates to:
  /// **'Don\'t wait. Let drivers find you.'**
  String get zeroResultsHeadline;

  /// Zero results subtext with full route and date
  ///
  /// In en, this message translates to:
  /// **'Post a request for {origin} to {destination} on {date}.'**
  String zeroResultsRouteDate(String origin, String destination, String date);

  /// Zero results subtext with route only
  ///
  /// In en, this message translates to:
  /// **'Post a request for {origin} to {destination}.'**
  String zeroResultsRoute(String origin, String destination);

  /// Zero results subtext with origin and date
  ///
  /// In en, this message translates to:
  /// **'Post a request from {origin} on {date}.'**
  String zeroResultsOriginDate(String origin, String date);

  /// Zero results subtext with origin only
  ///
  /// In en, this message translates to:
  /// **'Post a request from {origin} and let drivers find you.'**
  String zeroResultsOrigin(String origin);

  /// Zero results subtext with no criteria
  ///
  /// In en, this message translates to:
  /// **'Post a request for your route and let drivers find you.'**
  String get zeroResultsGeneric;

  /// Checkbox label to mark price as negotiable
  ///
  /// In en, this message translates to:
  /// **'Price negotiable'**
  String get negotiablePrice;

  /// Button label to add intermediate stop
  ///
  /// In en, this message translates to:
  /// **'Add stop'**
  String get addStop;

  /// Tooltip for removing intermediate stop
  ///
  /// In en, this message translates to:
  /// **'Remove stop'**
  String get removeStop;

  /// Label for intermediate stop city field
  ///
  /// In en, this message translates to:
  /// **'Stop {number}'**
  String intermediateStopLabel(int number);

  /// Label for intermediate stop time field
  ///
  /// In en, this message translates to:
  /// **'Departure time at stop'**
  String get stopDepartureTime;

  /// Button label to trigger proximity search
  ///
  /// In en, this message translates to:
  /// **'Expand search'**
  String get expandSearch;

  /// Helper text below expand search button
  ///
  /// In en, this message translates to:
  /// **'Looks for offers close to your origin and destination.'**
  String get expandSearchHelper;

  /// Section header for nearby/proximity results
  ///
  /// In en, this message translates to:
  /// **'Approximate matches'**
  String get approximateMatchesHeader;

  /// Shown when proximity search returns no rides
  ///
  /// In en, this message translates to:
  /// **'No nearby rides found'**
  String get noNearbyRidesFound;

  /// Shown when proximity search returns no seat requests
  ///
  /// In en, this message translates to:
  /// **'No nearby requests found'**
  String get noNearbyRequestsFound;

  /// Distance hint shown next to city name on nearby offer cards
  ///
  /// In en, this message translates to:
  /// **'+{km} km'**
  String distanceHint(int km);

  /// Title on verify-result screen when verification succeeds
  ///
  /// In en, this message translates to:
  /// **'Email verified!'**
  String get emailVerifiedSuccess;

  /// Title on verify-result screen when verification fails
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get emailVerificationFailed;

  /// Snackbar after resend verification email succeeds
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get verificationEmailSent;

  /// Button label to resend a verification email
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerificationEmail;

  /// Snackbar when email is already verified (409)
  ///
  /// In en, this message translates to:
  /// **'Email is already verified'**
  String get emailAlreadyVerified;

  /// Snackbar when resend is rate-limited (429)
  ///
  /// In en, this message translates to:
  /// **'Try again in {seconds}s'**
  String verificationCooldown(int seconds);

  /// Button on verify-result success screen to go to rides
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueToApp;

  /// Message on verify-result when user is not signed in
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get signInToContinue;

  /// Success message on verify-result for unauthenticated users
  ///
  /// In en, this message translates to:
  /// **'Email verified. Please sign in to continue.'**
  String get emailVerifiedSignIn;

  /// Button to navigate to login from verify-result screen
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get goToLogin;

  /// Error message for unauthenticated users on verify-result
  ///
  /// In en, this message translates to:
  /// **'Please sign in and request a new verification email.'**
  String get requestNewVerification;

  /// Generic error for verification resend failure
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericVerificationError;
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
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
