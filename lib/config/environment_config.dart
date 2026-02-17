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
.p  static String get baseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.vamigo.app';
      case 'staging':
        return 'https://api.vamigo.app';
      case 'development':
      default:
        return 'https://api.vamigo.app';
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

  /// Photon geocoding API base URI.
  ///
  /// Override via: --dart-define=PHOTON_URL=http://localhost:2322
  static Uri get photonUri {
    const override = String.fromEnvironment('PHOTON_URL', defaultValue: '');
    if (override.isNotEmpty) return _normalizeUri(override);

    return Uri.parse('https://ac.vamigo.app');
  }

  static Uri _normalizeUri(String raw) {
    var uri = Uri.parse(raw);
    if (!uri.hasScheme) uri = Uri.parse('https://$raw');
    // Strip trailing slash from path
    if (uri.path.endsWith('/')) {
      uri = uri.replace(path: uri.path.substring(0, uri.path.length - 1));
    }
    return uri;
  }

  /// Print current configuration
  static void printConfig() {
    print('=== Environment Configuration ===');
    print('Environment: $environment');
    print('Base URL: $baseUrl');
    print('Auth Base URL: $authBaseUrl');
    print('API Base URL: $apiBaseUrl');
    print('API Timeout: ${apiTimeoutSeconds}s');
    print('Photon URI: $photonUri');
    print('================================');
  }
}
