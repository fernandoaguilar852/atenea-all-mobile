import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/config/theme_config.dart';
import '../providers/chat_provider.dart';

class ChatFloatingButton extends ConsumerWidget {
  const ChatFloatingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      right: 16.w,
      bottom: 16.h,
      child: FloatingActionButton(
        heroTag: 'chat_fab',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const ChatDialog(),
          );
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.chat_bubble_outline, color: AppColors.white),
      ),
    );
  }
}

class ChatDialog extends ConsumerStatefulWidget {
  const ChatDialog({super.key});

  @override
  ConsumerState<ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends ConsumerState<ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    await ref.read(chatProvider.notifier).sendMessage(message);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        height: 600.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          color: AppColors.white,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.smart_toy,
                      color: AppColors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chat IA ATENEA',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Asistente virtual',
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.8),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: chatState.messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64.sp,
                            color: AppColors.grey300,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            '¡Hola! Soy tu asistente ATENEA',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Pregúntame sobre ventas, productos,\nclientes o cualquier cosa',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16.w),
                      itemCount: chatState.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatState.messages[index];
                        return _MessageBubble(
                          message: message.content,
                          isUser: message.isUser,
                          timestamp: message.timestamp,
                        );
                      },
                    ),
            ),

            // Loading indicator
            if (chatState.isLoading)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.smart_toy,
                        size: 20.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Escribiendo...',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            // Input
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                border: Border(
                  top: BorderSide(color: AppColors.borderColor, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: AppColors.white),
                      onPressed: chatState.isLoading ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  const _MessageBubble({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                size: 20.sp,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.grey100,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isUser ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 20.sp,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
