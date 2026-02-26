import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/messaging_provider.dart';
import '../widgets/message_bubble.dart';

/// Chat screen for messaging with a specific user
class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String currentUserId;
  final VoidCallback? onBackPressed;

  const ChatScreen({
    required this.conversationId,
    required this.otherUserName,
    required this.currentUserId,
    this.onBackPressed,
    super.key,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesStreamProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
        ),
        title: Text(
          widget.otherUserName,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSent = message.senderId == widget.currentUserId;

                    return MessageBubble(
                      text: message.text,
                      timestamp: message.createdAt,
                      isSent: isSent,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border, width: 1),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type here',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: AppColors.textInverse,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    await ref.read(sendMessageProvider((
      widget.conversationId,
      widget.currentUserId,
      text,
    )).future);
  }
}
