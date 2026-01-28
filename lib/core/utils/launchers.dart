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

  /// Open URL in external browser.
  ///
  /// Ensures URL has a scheme (prepends https:// if missing).
  /// Returns true if the URL was opened successfully.
  static Future<bool> openUrl(String url) async {
    // Ensure URL has a scheme
    String normalizedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      normalizedUrl = 'https://$url';
    }

    final uri = Uri.parse(normalizedUrl);

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
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
