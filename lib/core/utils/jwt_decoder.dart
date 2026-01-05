import 'dart:convert';

/// Pure Dart JWT decoder for token validation without external dependencies
class JwtDecoder {
  /// Checks if a JWT token is expired
  ///
  /// Returns true if the token is expired or invalid.
  /// Includes a 30-second buffer for clock skew.
  static bool isTokenExpired(String token) {
    try {
      final expirationDate = getExpirationDate(token);
      if (expirationDate == null) {
        return true; // No expiration means invalid token
      }

      // Add 30-second buffer for clock skew
      final now = DateTime.now();
      final buffer = const Duration(seconds: 30);
      return expirationDate.isBefore(now.add(buffer));
    } catch (e) {
      return true; // If we can't decode, consider it expired
    }
  }

  /// Extracts the expiration date from a JWT token
  ///
  /// Returns null if the token is invalid or doesn't have an exp claim.
  static DateTime? getExpirationDate(String token) {
    try {
      final payload = decodePayload(token);
      if (payload == null || !payload.containsKey('exp')) {
        return null;
      }

      final exp = payload['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Decodes the payload section of a JWT token
  ///
  /// Returns a Map containing the payload claims, or null if invalid.
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      // Decode the payload (second part)
      final payload = parts[1];

      // Base64 URL decoding with padding normalization
      String normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));

      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Gets the user ID from the JWT token
  ///
  /// Common JWT claims: sub, userId, user_id, id
  static String? getUserId(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    return payload['sub']?.toString() ??
        payload['userId']?.toString() ??
        payload['user_id']?.toString() ??
        payload['id']?.toString();
  }

  /// Checks if the token is valid (not expired and properly formatted)
  static bool isTokenValid(String token) {
    try {
      final payload = decodePayload(token);
      if (payload == null) return false;

      return !isTokenExpired(token);
    } catch (e) {
      return false;
    }
  }
}
