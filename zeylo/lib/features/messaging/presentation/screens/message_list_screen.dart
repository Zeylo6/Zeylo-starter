import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/messaging_provider.dart';
import '../widgets/conversation_tile.dart';

/// Message list screen showing all conversations
class MessageListScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;
  final Function(String conversationId, String otherUserId)? onConversationSelected;

  const MessageListScreen({
    required this.userId,
    required this.userName,
    this.onConversationSelected,
    super.key,
  });

  @override
  ConsumerState<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends ConsumerState<MessageListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsStreamProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: AppColors.background.withOpacity(0.85)),
          ),
        ),
        title: Text(
          widget.userName,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: ZeyloTextField(
                label: 'Search',
                hint: 'Search conversations',
                controller: _searchController,
                prefixWidget: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            // Conversations list
            Expanded(
              child: conversationsAsync.when(
                data: (conversations) {
                  if (conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No conversations yet',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Start a conversation from a user\'s profile',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final otherUserId = conversation.participants
                          .firstWhere((id) => id != widget.userId, orElse: () => widget.userId);

                      final isUnread = conversation.lastMessage != null &&
                          !conversation.lastMessage!.isRead &&
                          conversation.lastMessage!.senderId != widget.userId;

                      return Dismissible(
                        key: ValueKey(conversation.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppSpacing.lg),
                          color: AppColors.error,
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Conversation?'),
                              content: const Text('This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          // Handle delete logic here natively down the line
                        },
                        child: _ConversationItem(
                          otherUserId: otherUserId,
                          conversationId: conversation.id,
                          lastMessage: conversation.lastMessage?.text,
                          lastMessageTime: conversation.lastMessageAt,
                          searchQuery: _searchQuery,
                          currentUserId: widget.userId,
                          isUnread: isUnread,
                          onConversationSelected: widget.onConversationSelected,
                        ),
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
          ],
        ),
      ),
    );
  }
}

/// Individual conversation item that fetches the other user's profile
class _ConversationItem extends ConsumerWidget {
  final String otherUserId;
  final String conversationId;
  final String? lastMessage;
  final DateTime lastMessageTime;
  final String searchQuery;
  final String currentUserId;
  final bool isUnread;
  final Function(String conversationId, String otherUserId)? onConversationSelected;

  const _ConversationItem({
    required this.otherUserId,
    required this.conversationId,
    this.lastMessage,
    required this.lastMessageTime,
    required this.searchQuery,
    required this.currentUserId,
    this.isUnread = false,
    this.onConversationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(otherUserId));

    return profileAsync.when(
      data: (profile) {
        final displayName = profile.name;
        final photoUrl = profile.photoUrl;

        // Filter by search query against display name
        if (searchQuery.isNotEmpty &&
            !displayName.toLowerCase().contains(searchQuery)) {
          return const SizedBox.shrink();
        }

        return ConversationTile(
          userId: otherUserId,
          userName: displayName,
          userPhotoUrl: photoUrl,
          lastMessage: lastMessage,
          lastMessageTime: lastMessageTime,
          isUnread: isUnread,
          onPressed: () {
            if (onConversationSelected != null) {
              onConversationSelected!(conversationId, otherUserId);
            } else {
              context.push('/chat/$conversationId', extra: {
                'otherUserName': displayName,
                'currentUserId': currentUserId,
              });
            }
          },
        );
      },
      loading: () => ConversationTile(
        userId: otherUserId,
        userName: '...',
        lastMessage: lastMessage,
        lastMessageTime: lastMessageTime,
        isUnread: isUnread,
        onPressed: () {},
      ),
      error: (_, __) => ConversationTile(
        userId: otherUserId,
        userName: 'User',
        lastMessage: lastMessage,
        lastMessageTime: lastMessageTime,
        isUnread: isUnread,
        onPressed: () {
          context.push('/chat/$conversationId', extra: {
            'otherUserName': 'User',
            'currentUserId': currentUserId,
          });
        },
      ),
    );
  }
}
