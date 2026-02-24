import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_text_field.dart';
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
    Key? key,
  }) : super(key: key);

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
        backgroundColor: AppColors.background,
        title: Text(
          widget.userName,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ZeyloTextField(
              label: 'Search',
              hint: 'Search',
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
                final filtered = conversations
                    .where((conv) {
                      // Get the other participant's name (if available)
                      final otherUserId = conv.participants
                          .firstWhere((id) => id != widget.userId);
                      return otherUserId.toLowerCase().contains(_searchQuery);
                    })
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No conversations yet'
                          : 'No results found',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final conversation = filtered[index];
                    final otherUserId = conversation.participants
                        .firstWhere((id) => id != widget.userId);

                    return ConversationTile(
                      userId: otherUserId,
                      userName: 'User $otherUserId', // Get from profile in real app
                      lastMessage: conversation.lastMessage?.text,
                      lastMessageTime: conversation.lastMessageAt,
                      onPressed: () {
                        widget.onConversationSelected?.call(
                          conversation.id,
                          otherUserId,
                        );
                      },
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
    );
  }
}
