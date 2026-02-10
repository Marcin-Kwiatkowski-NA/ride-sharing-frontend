// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vamos Ride Sharing';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String comingSoon(String feature) {
    return '$feature coming soon!';
  }

  @override
  String get or => 'OR';

  @override
  String get required => 'Required';

  @override
  String get navRides => 'Rides';

  @override
  String get navPackages => 'Packages';

  @override
  String get navProfile => 'Profile';

  @override
  String get navMessages => 'Messages';

  @override
  String get loginTitle => 'Login';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign up';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get displayNameLabel => 'Display Name';

  @override
  String get displayNameHelper => 'This is the name other users will see.';

  @override
  String get enterDisplayName => 'Enter a display name';

  @override
  String get displayNameMinLength =>
      'Display name must be at least 2 characters';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPassword => 'Confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get enterAPassword => 'Enter a password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get googleSignUpComingSoon => 'Google sign-up coming soon!';

  @override
  String searchSemanticLabel(String label) {
    return 'Search for rides. $label';
  }

  @override
  String get swapOriginDestination => 'Swap origin and destination';

  @override
  String get whereToSearch => 'Where to?';

  @override
  String searchFromCity(String city) {
    return 'From $city';
  }

  @override
  String searchToCity(String city) {
    return 'To $city';
  }

  @override
  String searchRoute(String origin, String destination) {
    return '$origin → $destination';
  }

  @override
  String get myRides => 'My Rides';

  @override
  String get post => 'Post';

  @override
  String get whatAreYouPosting => 'What are you posting?';

  @override
  String get offerARide => 'Offer a Ride';

  @override
  String get offerARideSubtitle => 'I\'m driving and have empty seats.';

  @override
  String get requestARide => 'Request a Ride';

  @override
  String get requestARideSubtitle => 'I need a driver for a specific date.';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get partOfDayMorning => 'Morning';

  @override
  String get partOfDayAfternoon => 'Afternoon';

  @override
  String get partOfDayEvening => 'Evening';

  @override
  String get partOfDayNight => 'Night';

  @override
  String get anyTime => 'Any time';

  @override
  String get flexible => 'Flexible';

  @override
  String get askDriver => 'Ask driver';

  @override
  String get askAboutPrice => 'Ask about price';

  @override
  String get askPassenger => 'Ask passenger';

  @override
  String offerDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String dateStripDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String formattedPrice(int price) {
    return '$price PLN';
  }

  @override
  String seatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seats',
      one: '1 seat',
    );
    return '$_temp0';
  }

  @override
  String passengerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passengers',
      one: '1 passenger',
    );
    return '$_temp0';
  }

  @override
  String rideCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rides',
      one: '1 ride',
    );
    return '$_temp0';
  }

  @override
  String get pricePerSeat => 'Price per seat';

  @override
  String get availableSeats => 'Available seats';

  @override
  String get budget => 'Budget';

  @override
  String get passengers => 'Passengers';

  @override
  String get passengersNeeded => 'Passengers Needed';

  @override
  String get verifiedMember => 'Verified member';

  @override
  String get communityListing => 'Community listing';

  @override
  String get sourceFacebook => 'Source: Facebook';

  @override
  String get callLabel => 'Call';

  @override
  String get openFacebookPost => 'Open Facebook post';

  @override
  String get sendEmail => 'Send email';

  @override
  String get rideDetails => 'Ride Details';

  @override
  String get rideRequest => 'Ride Request';

  @override
  String get offeringARide => 'Offering a ride';

  @override
  String get lookingForARide => 'Looking for a ride';

  @override
  String contactUser(String name) {
    return 'Contact $name';
  }

  @override
  String get facebookUser => 'Facebook User';

  @override
  String get priceLabel => 'Price';

  @override
  String get availabilityLabel => 'Availability';

  @override
  String get driverLabel => 'DRIVER';

  @override
  String get passengerLabel => 'PASSENGER';

  @override
  String get driverFallbackName => 'Driver';

  @override
  String get passengerFallbackName => 'Passenger';

  @override
  String ratingDisplay(String rating, int count) {
    return '$rating ($count)';
  }

  @override
  String get statusOpen => 'Open';

  @override
  String get statusFull => 'Full';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusSearching => 'Searching';

  @override
  String get statusBooked => 'Booked';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusBanned => 'Banned';

  @override
  String get noRidesFound => 'No rides found matching your criteria.';

  @override
  String get noPassengerRequests =>
      'No passenger requests found matching your criteria.';

  @override
  String get myOffers => 'My Offers';

  @override
  String get filterAll => 'All';

  @override
  String get filterRides => 'Rides';

  @override
  String get filterPassengers => 'Passengers';

  @override
  String get failedToLoadOffers => 'Failed to load offers';

  @override
  String get noOffersYet => 'No offers yet';

  @override
  String get postYourRide => 'Post Your Ride';

  @override
  String get offerARideHeader => 'Offer a Ride';

  @override
  String get originCityLabel => 'Origin City';

  @override
  String get destinationCityLabel => 'Destination City';

  @override
  String get originRequired => 'Origin City is required';

  @override
  String get destinationRequired => 'Destination City is required';

  @override
  String get selectOriginFromSuggestions => 'Select origin from suggestions';

  @override
  String get selectDestinationFromSuggestions =>
      'Select destination from suggestions';

  @override
  String get mustDifferFromOrigin => 'Must differ from origin';

  @override
  String get dateOfDeparture => 'Date of Departure';

  @override
  String get selectDepartureDate => 'Select departure date';

  @override
  String get timeOfDay => 'Time of Day';

  @override
  String get timeOfDeparture => 'Time of Departure';

  @override
  String get selectDepartureTime => 'Select departure time';

  @override
  String get availableSeatsLabel => 'Available Seats';

  @override
  String get seatsRange => '1-8 seats allowed';

  @override
  String get pricePerSeatLabel => 'Price per Seat';

  @override
  String get priceRange => '1-999 PLN';

  @override
  String get rideDescriptionOptional => 'Ride Description (Optional)';

  @override
  String maxCharacters(int count) {
    return 'Max $count characters';
  }

  @override
  String get postRide => 'Post Ride';

  @override
  String get postSeatRequest => 'Post Seat Request';

  @override
  String get findARideHeader => 'Find a Ride';

  @override
  String get passengersRange => '1-8 passengers allowed';

  @override
  String get budgetOptional => 'Budget (Optional)';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get seatRequestCreated => 'Seat request created successfully!';

  @override
  String get profileTitle => 'Profile';

  @override
  String get logInToSeeProfile => 'Log in to see your profile';

  @override
  String get logInSignUp => 'Log In / Sign Up';

  @override
  String get trustAndVerification => 'Trust & Verification';

  @override
  String get emailVerification => 'Email verification';

  @override
  String get phoneVerification => 'Phone verification';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get statistics => 'Statistics';

  @override
  String get ridesGiven => 'Rides Given';

  @override
  String get ridesTaken => 'Rides Taken';

  @override
  String get rating => 'Rating';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get updatePersonalInfo => 'Update your personal information';

  @override
  String get viewRideHistory => 'View your ride history';

  @override
  String get logout => 'Logout';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get phoneHint => 'Enter your phone number (optional)';

  @override
  String get bioLabel => 'Bio';

  @override
  String get bioHint => 'Tell others about yourself (optional)';

  @override
  String get displayNameRequired => 'Display name is required';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get failedToUpdateProfile => 'Failed to update profile';

  @override
  String get profileCompleteness => 'Profile Completeness';

  @override
  String get profileComplete => 'Profile complete!';

  @override
  String percentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String get complete => 'Complete';

  @override
  String get profileNotAvailable => 'Profile not available';

  @override
  String get profileNotAvailableMessage =>
      'This profile cannot be displayed right now.';

  @override
  String get about => 'About';

  @override
  String get noBioYet => 'No bio added yet.';

  @override
  String get rides => 'Rides';

  @override
  String get reviews => 'Reviews';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get bookingsComingSoon => 'Bookings Coming Soon';

  @override
  String get bookingsComingSoonMessage =>
      'The booking feature is being redesigned. Check back later!';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get chatTitle => 'Chat';

  @override
  String get couldNotLoadMessages => 'Could not load messages';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get startConversation => 'Start a conversation from a ride listing';

  @override
  String get sendMessageToStart => 'Send a message to start the conversation';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get timeNow => 'now';

  @override
  String timeMinutesAgo(int count) {
    return '${count}m';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h';
  }

  @override
  String timeDaysAgo(int count) {
    return '${count}d';
  }

  @override
  String get packagesTitle => 'Packages';

  @override
  String get packagesComingSoon => 'Coming soon';

  @override
  String get errorTitle => 'Error';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get pageNotFoundMessage =>
      'The page you are looking for does not exist.';

  @override
  String get goHome => 'Go Home';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePolish => 'Polski';

  @override
  String effectiveLanguage(String language) {
    return 'Currently using: $language';
  }

  @override
  String get searchRides => 'Search Rides';

  @override
  String get searchPassengers => 'Search Passengers';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get dateLabel => 'Date';

  @override
  String get anyDate => 'Any date';

  @override
  String get clearDate => 'Clear date';

  @override
  String get clearAll => 'Clear All';

  @override
  String get chooseCity => 'Choose city';

  @override
  String get searchCity => 'Search city';

  @override
  String get whereAreYouGoing => 'Where are you going?';

  @override
  String nudgeRouteTime(String origin, String destination) {
    return 'Need a different time for $origin → $destination?';
  }

  @override
  String nudgeDateFallback(String date) {
    return 'Nothing on $date? Post your own request.';
  }

  @override
  String get nudgeGeneric =>
      'Not finding what you need? Post a request and let drivers come to you.';

  @override
  String get postARequest => 'Post a request';

  @override
  String get postRequest => 'Post Request';

  @override
  String get noRidesFoundShort => 'No rides found';

  @override
  String get zeroResultsHeadline => 'Don\'t wait. Let drivers find you.';

  @override
  String zeroResultsRouteDate(String origin, String destination, String date) {
    return 'Post a request for $origin to $destination on $date.';
  }

  @override
  String zeroResultsRoute(String origin, String destination) {
    return 'Post a request for $origin to $destination.';
  }

  @override
  String zeroResultsOriginDate(String origin, String date) {
    return 'Post a request from $origin on $date.';
  }

  @override
  String zeroResultsOrigin(String origin) {
    return 'Post a request from $origin and let drivers find you.';
  }

  @override
  String get zeroResultsGeneric =>
      'Post a request for your route and let drivers find you.';
}
