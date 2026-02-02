import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/chat_repository.dart';
import '../../domain/chat_presentation.dart';
import '../../domain/conversation_ui_model.dart';

part 'inbox_provider.g.dart';

@riverpod
Future<List<ConversationUiModel>> inbox(Ref ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  final conversations = await repository.getConversations();
  return ChatPresentation.toConversationUiModels(conversations);
}
