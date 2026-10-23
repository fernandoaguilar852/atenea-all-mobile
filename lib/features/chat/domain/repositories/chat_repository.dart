import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<String> sendMessage(String message);
  Future<List<ChatMessage>> getChatHistory();
  Future<void> clearChatHistory();
}
