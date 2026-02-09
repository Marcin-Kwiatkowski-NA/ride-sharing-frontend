import 'package:flutter/widgets.dart';

import '../../domain/offer_models.dart';
import '../../domain/offer_ui_model.dart';

/// Presentation-layer label derivation for the offer details screen.
///
/// Instance-based with [BuildContext] so swapping to `AppLocalizations`
/// later only changes internals, not call sites.
class OfferDetailsStrings {
  const OfferDetailsStrings(this.context);
  final BuildContext context;

  String screenTitle(OfferKind kind) => switch (kind) {
    OfferKind.ride => 'Ride Details',
    OfferKind.seat => 'Ride Request',
  };

  String roleLabel(OfferKind kind) => switch (kind) {
    OfferKind.ride => 'Offering a ride',
    OfferKind.seat => 'Looking for a ride',
  };

  String contactLabel({required OfferUserUi user}) =>
      'Contact ${user.displayName}';

  String driverSubtitle(OfferKind kind, {required bool isExternalSource}) {
    if (isExternalSource) return 'Facebook User';
    return roleLabel(kind);
  }

  String get priceLabel => 'Price';

  String get availabilityLabel => 'Availability';
}
