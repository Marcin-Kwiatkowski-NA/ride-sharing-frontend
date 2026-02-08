import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nudge_dismissed_provider.g.dart';

/// Tracks whether the user has dismissed the "post request" nudge card
/// for the current session. Once dismissed, stays hidden until app restart.
@Riverpod(keepAlive: true)
class NudgeDismissed extends _$NudgeDismissed {
  @override
  bool build() => false;

  void dismiss() => state = true;
}
