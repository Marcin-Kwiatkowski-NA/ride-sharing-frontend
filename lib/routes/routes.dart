/// Named route constants for go_router
abstract class RouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const createAccount = 'create-account';
  static const rides = 'rides';
  static const rideDetails = 'ride-details';
  static const passengers = 'passengers';
  static const profile = 'profile';
  static const editProfile = 'edit-profile';
  static const messages = 'messages';
  static const chat = 'chat';
  static const postRide = 'post-ride';
}

/// Route paths (used only in router config)
abstract class RoutePaths {
  static const root = '/';
  static const splash = '/splash';
  static const login = '/login';
  static const createAccount = '/create-account';
  static const rides = '/rides';
  static const rideDetails = ':rideId'; // Nested under /rides
  static const passengers = '/passengers';
  static const profile = '/profile';
  static const editProfile = 'edit'; // Nested under /profile
  static const messages = '/messages';
  static const chat = '/chat/:conversationId';
  static const postRide = '/post-ride';
}
