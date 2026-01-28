/// Immutable pair of JWT tokens for authentication.
///
/// Contains both the short-lived access token and the long-lived refresh token.
/// Used throughout the app for token management and refresh flows.
class TokenPair {
  final String accessToken;
  final String refreshToken;

  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
  });

  /// Creates a TokenPair with an empty refresh token.
  /// Used for graceful degradation when backend doesn't return refresh token.
  factory TokenPair.accessOnly(String accessToken) {
    return TokenPair(accessToken: accessToken, refreshToken: '');
  }

  /// Whether this pair has a valid refresh token.
  bool get hasRefreshToken => refreshToken.isNotEmpty;
}
