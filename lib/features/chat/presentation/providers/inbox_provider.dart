import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blablafront/core/providers/auth_session_provider.dart';
import '../../data/chat_repository.dart';
import '../../domain/chat_presentation.dart';
import '../../domain/conversation_ui_model.dart';

part 'inbox_provider.g.dart';

/// Provides the user's conversation inbox.
///
/// Behavior:
/// - When unauthenticated: returns empty list (no API call)
/// - When authenticated: fetches conversations from API
/// - Auto-refetches when user logs in
/// - Auto-clears when user logs out
/// - Cancels in-flight requests on session change (prevents stale data)
@riverpod
Future<List<ConversationUiModel>> inbox(Ref ref) async {
  // Watch session key - triggers rebuild on login/logout/user change
  final sessionKey = ref.watch(authSessionKeyProvider);

  // Not authenticated - return empty immediately (no API call)
  if (sessionKey == null) {
    return [];
  }

  // Create cancel token for this request - cancelled on dispose (session change)
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel('Session changed'));

  // Authenticated - fetch from API
  final repository = ref.watch(chatRepositoryProvider);
  final conversations = await repository.getConversations(
    cancelToken: cancelToken,
  );
  return ChatPresentation.toConversationUiModels(conversations);
}
