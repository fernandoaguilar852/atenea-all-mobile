import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../models/chat_message.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Dio _dio;

  ChatNotifier(this._dio) : super(ChatState());

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Agregar mensaje del usuario
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      // Llamar al API
      final response = await _dio.post(
        ApiConstants.buildUrl(ApiConstants.chatQuery),
        data: {'message': message},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final aiResponse = response.data['data']['answer'] as String;

        // Agregar respuesta de la IA
        final aiMessage = ChatMessage(
          id: const Uuid().v4(),
          content: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        );

        state = state.copyWith(
          messages: [...state.messages, aiMessage],
          isLoading: false,
        );
      } else {
        throw Exception('Error al obtener respuesta');
      }
    } catch (e) {
      debugPrint('Error en chat: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Error al enviar mensaje. Intenta de nuevo.',
      );

      // Agregar mensaje de error
      final errorMessage = ChatMessage(
        id: const Uuid().v4(),
        content: 'Lo siento, hubo un error. ¿Puedes intentar de nuevo?',
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
      );
    }
  }

  void clearChat() {
    state = ChatState();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChatNotifier(dioClient.dio);
});
