import 'package:url_launcher/url_launcher.dart';

/// Utility class for launching external actions.
class Launchers {
  Launchers._();

  /// Make a phone call.
  ///
  /// Returns true if the call was launched successfully.
  static Future<bool> makePhoneCall(String phoneNumber) async {
    // Normalize phone number (remove spaces)
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$normalizedPhone');

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  /// Open URL in external browser or app.
  ///
  /// Ensures URL has a scheme (prepends https:// if missing).
  /// Launches directly without canLaunchUrl gate to avoid false negatives
  /// on Android 11+ package visibility restrictions.
  static Future<bool> openUrl(String url) async {
    String normalizedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      normalizedUrl = 'https://$url';
    }

    final uri = Uri.parse(normalizedUrl);

    try {
      return await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (_) {
      return false;
    }
  }

  /// Send SMS.
  static Future<bool> sendSms(String phoneNumber, {String? body}) async {
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse(
      'sms:$normalizedPhone${body != null ? '?body=${Uri.encodeComponent(body)}' : ''}',
    );

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  /// Send email.
  static Future<bool> sendEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    final queryParams = <String, String>{};
    if (subject != null) queryParams['subject'] = subject;
    if (body != null) queryParams['body'] = body;

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }
}
