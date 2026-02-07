import 'package:flutter/material.dart';

import '../data/offer_enums.dart';
import 'offer_ui_model.dart';

/// UI representation of a contact method for display in bottom sheet.
@immutable
class ContactMethodUi {
  final ContactType type;
  final String value;
  final String label;
  final String preview;
  final IconData icon;

  const ContactMethodUi({
    required this.type,
    required this.value,
    required this.label,
    required this.preview,
    required this.icon,
  });
}

/// Polymorphic chat context for creating conversations.
///
/// Explicitly models the context type + id so the chat system
/// doesn't assume offerKey.id is always a rideId.
@immutable
class ChatContext {
  final OfferKind kind;
  final int id;

  const ChatContext(this.kind, this.id);

  String get key => '${kind == OfferKind.ride ? 'r' : 's'}-$id';
}

/// Cohesive nested object for user display + contact actions.
///
/// Consumed by OfferUserSection, ContactUserButton, and ContactUserSheet.
@immutable
class OfferUserUi {
  // Display
  final String sectionTitle;
  final String displayName;
  final double? rating;
  final int? completedTrips;
  final bool showRating;

  // Contact
  final int? userId;
  final bool canUseInAppChat;
  final ChatContext chatContext;
  final List<ContactMethodUi> contactMethods;

  const OfferUserUi({
    required this.sectionTitle,
    required this.displayName,
    required this.rating,
    required this.completedTrips,
    required this.showRating,
    required this.userId,
    required this.canUseInAppChat,
    required this.chatContext,
    required this.contactMethods,
  });

  bool get hasAnyContactAction => canUseInAppChat || contactMethods.isNotEmpty;

  bool get hasPhoneContact =>
      contactMethods.any((c) => c.type == ContactType.phone);

  bool get hasFacebookLink =>
      contactMethods.any((c) => c.type == ContactType.facebookLink);

  bool get hasEmailContact =>
      contactMethods.any((c) => c.type == ContactType.email);
}
