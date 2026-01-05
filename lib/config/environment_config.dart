/// Environment configuration for API URLs and app settings
///
/// Supports different environments via --dart-define flag:
/// flutter run --dart-define=ENV=development
/// flutter build apk --dart-define=ENV=production
class EnvironmentConfig {
  /// Current environment (development, staging, production)
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  /// Base URL for all API endpoints
  ///
  /// Using sslip.io for dynamic DNS resolution
  /// IMPORTANT: Should be HTTPS in production
  static String get baseUrl {
    switch (environment) {
      case 'production':
        return 'https://vamos.130.61.31.172.sslip.io';
      case 'staging':
        return 'https://vamos-staging.130.61.31.172.sslip.io';
      case 'development':
      default:
        return 'https://vamos.130.61.31.172.sslip.io';
    }
  }

  /// Auth API base URL
  static String get authBaseUrl => baseUrl;

  /// Main API base URL
  static String get apiBaseUrl => baseUrl;

  /// Whether the app is running in production
  static bool get isProduction => environment == 'production';

  /// Whether the app is running in development
  static bool get isDevelopment => environment == 'development';

  /// Whether the app is running in staging
  static bool get isStaging => environment == 'staging';

  /// API timeout duration in seconds
  static int get apiTimeoutSeconds {
    switch (environment) {
      case 'development':
        return 30;
      case 'staging':
        return 20;
      case 'production':
      default:
        return 15;
    }
  }

  /// Print current configuration
  static void printConfig() {
    print('=== Environment Configuration ===');
    print('Environment: $environment');
    print('Base URL: $baseUrl');
    print('Auth Base URL: $authBaseUrl');
    print('API Base URL: $apiBaseUrl');
    print('API Timeout: ${apiTimeoutSeconds}s');
    print('================================');
  }
}
