import 'package:flutter/widgets.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../domain/offer_models.dart';
import '../../domain/offer_ui_model.dart';

/// Presentation-layer label derivation for the offer details screen.
///
/// Instance-based with [BuildContext] so localized strings are resolved
/// via [AppLocalizations].
class OfferDetailsStrings {
  const OfferDetailsStrings(this.context);
  final BuildContext context;

  String screenTitle(OfferKind kind) => switch (kind) {
    OfferKind.ride => context.l10n.rideDetails,
    OfferKind.seat => context.l10n.rideRequest,
  };

  String roleLabel(OfferKind kind) => switch (kind) {
    OfferKind.ride => context.l10n.offeringARide,
    OfferKind.seat => context.l10n.lookingForARide,
  };

  String contactLabel({required OfferUserUi user}) =>
      context.l10n.contactUser(user.displayName);

  String driverSubtitle(OfferKind kind, {required bool isExternalSource}) {
    if (isExternalSource) return context.l10n.facebookUser;
    return roleLabel(kind);
  }

  String get priceLabel => context.l10n.priceLabel;

  String get availabilityLabel => context.l10n.availabilityLabel;
}
