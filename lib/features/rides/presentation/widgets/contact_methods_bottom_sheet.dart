import 'package:flutter/material.dart';

import '../../../../core/utils/launchers.dart';
import '../../data/dto/ride_enums.dart';
import '../../domain/ride_ui_model.dart';

/// Shows the contact methods bottom sheet.
Future<void> showContactMethodsSheet(
  BuildContext context,
  RideUiModel ride,
) {
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => ContactMethodsBottomSheet(
      contactMethods: ride.contactMethods,
      onLaunchError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Could not open contact method'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    ),
  );
}

/// Modal bottom sheet displaying all available contact methods.
class ContactMethodsBottomSheet extends StatelessWidget {
  final List<ContactMethodUi> contactMethods;
  final void Function(String? error) onLaunchError;

  const ContactMethodsBottomSheet({
    super.key,
    required this.contactMethods,
    required this.onLaunchError,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contact driver',
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Contact methods list
          ...contactMethods.map(
            (method) => _ContactMethodTile(
              method: method,
              onLaunchError: onLaunchError,
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
        ],
      ),
    );
  }
}

class _ContactMethodTile extends StatelessWidget {
  final ContactMethodUi method;
  final void Function(String? error) onLaunchError;

  const _ContactMethodTile({
    required this.method,
    required this.onLaunchError,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(method.icon),
      title: Text(method.label),
      subtitle: Text(
        method.preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _handleTap(context),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    Navigator.pop(context);

    final success = await _launchContactMethod();
    if (!success) {
      onLaunchError(_getErrorMessage());
    }
  }

  Future<bool> _launchContactMethod() async {
    switch (method.type) {
      case ContactType.phone:
        return Launchers.makePhoneCall(method.value);
      case ContactType.facebookLink:
        return Launchers.openUrl(method.value);
      case ContactType.email:
        return Launchers.sendEmail(method.value);
    }
  }

  String _getErrorMessage() {
    switch (method.type) {
      case ContactType.phone:
        return 'Could not make phone call';
      case ContactType.facebookLink:
        return 'Could not open link';
      case ContactType.email:
        return 'Could not open email client';
    }
  }
}
