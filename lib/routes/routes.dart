/// Named route constants for go_router
abstract class RouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const createAccount = 'create-account';
  static const rides = 'rides';
  static const ridesList = 'rides-list';
  static const seatsList = 'seats-list';
  static const offerDetails = 'offer-details';
  static const packages = 'packages';
  static const profile = 'profile';
  static const editProfile = 'edit-profile';
  static const messages = 'messages';
  static const chat = 'chat';
  static const postRide = 'post-ride';
  static const postSeat = 'post-seat';
  static const myOffers = 'my-offers';
  static const publicProfile = 'public-profile';
  static const devGallery = 'dev-gallery';
  static const verifyResult = 'verify-result';
}

/// Route paths (used only in router config)
abstract class RoutePaths {
  static const root = '/';
  static const splash = '/splash';
  static const login = '/login';
  static const createAccount = '/create-account';
  static const rides = '/rides';
  static const ridesList = 'list'; // Nested under /rides
  static const seatsList = 'seats'; // Nested under /rides
  static const offerDetails = 'offer/:offerKey'; // Nested under /rides
  static const packages = '/packages';
  static const profile = '/profile';
  static const editProfile = 'edit'; // Nested under /profile
  static const messages = '/messages';
  static const chat = '/chat/:conversationId';
  static const postRide = '/post-ride';
  static const postSeat = '/post-seat';
  static const myOffers = '/my-offers';
  static const publicProfile = '/user/:userId';
  static const devGallery = '/dev/gallery';
  static const verifyResult = '/verify-result';
}
