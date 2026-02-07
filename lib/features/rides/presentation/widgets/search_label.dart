/// Builds a human-readable label from origin and destination names.
///
/// Used by [HeroSearchCard] and [CompactSearchCapsule].
String buildSearchLabel({
  required String? originName,
  required String? destinationName,
  String emptyLabel = 'Where to?',
}) {
  if (originName != null && destinationName != null) {
    return '$originName \u2192 $destinationName';
  } else if (originName != null) {
    return 'From $originName';
  } else if (destinationName != null) {
    return 'To $destinationName';
  }
  return emptyLabel;
}
