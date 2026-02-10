import '../../../../l10n/generated/app_localizations.dart';

/// Builds a localized human-readable label from origin and destination names.
///
/// Used by [HeroSearchCard] and [CompactSearchCapsule].
String buildSearchLabel({
  required String? originName,
  required String? destinationName,
  required AppLocalizations l10n,
  String? emptyLabelOverride,
}) {
  if (originName != null && destinationName != null) {
    return l10n.searchRoute(originName, destinationName);
  } else if (originName != null) {
    return l10n.searchFromCity(originName);
  } else if (destinationName != null) {
    return l10n.searchToCity(destinationName);
  }
  return emptyLabelOverride ?? l10n.whereToSearch;
}
