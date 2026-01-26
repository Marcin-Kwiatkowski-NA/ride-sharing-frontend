import 'package:flutter/material.dart';
import 'package:blablafront/views/LoginScreen.dart';
import 'package:blablafront/views/CreateAccountScreen.dart';
import 'package:blablafront/views/Search_Ride_Screen.dart';
import 'package:blablafront/views/PostRideScreen.dart';
import 'package:blablafront/views/profile_screen.dart';
import 'package:blablafront/core/utils/route_guards.dart';
import 'package:blablafront/features/rides/presentation/screens/rides_list_screen.dart';
import 'package:blablafront/features/rides/presentation/screens/ride_details_screen.dart';

/// Route names for the application
class AppRoutes {
  static const String login = '/login';
  static const String createAccount = '/create-account';
  static const String home = '/home';
  static const String search = '/search';
  static const String postRide = '/post-ride';
  static const String profile = '/profile';
  static const String rides = '/rides';
  static const String rideDetails = '/rides/details';

  // Prevent instantiation
  AppRoutes._();
}

/// Centralized router with route guards
class AppRouter {
  // Prevent instantiation
  AppRouter._();

  /// Generate routes based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.createAccount:
        return MaterialPageRoute(
          builder: (_) => const CreateAccountScreen(),
          settings: settings,
        );

      case AppRoutes.home:
      case AppRoutes.search:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: SearchRideScreen()),
          settings: settings,
        );

      case AppRoutes.postRide:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: PostRideScreen()),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: ProfileScreen()),
          settings: settings,
        );

      case AppRoutes.rides:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: RidesListScreen()),
          settings: settings,
        );

      case AppRoutes.rideDetails:
        final rideId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => AuthGuard(child: RideDetailsScreen(rideId: rideId)),
          settings: settings,
        );

      default:
        // Unknown route - redirect to home
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: SearchRideScreen()),
          settings: settings,
        );
    }
  }

  /// Navigate to a named route
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replace current route with a named route
  static Future<T?> replaceTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.of(context).pushReplacementNamed<T, void>(routeName, arguments: arguments);
  }

  /// Clear stack and navigate to a named route
  static Future<T?> navigateAndClearStack<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
