import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/providers.dart';
import '../../domain/entities/message.dart';

/// Chat screen for group messaging
/// 
/// Features:
/// - Real-time group messages
/// - Send messages
/// - Shows sender names
/// - Message timestamps
class GroupChatScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Send a message to the group
  Future<void> _sendMessage() async {
    if (_isSending || _controller.text.trim().isEmpty) return;

    final content = _controller.text.trim();
    _controller.clear();

    setState(() => _isSending = true);

    try {
      final currentUserId = ref.read(currentUserIdProvider);
      final userProfile = await ref.read(currentUserProfileProvider.future);

      if (currentUserId == null || userProfile == null) {
        throw Exception('User not authenticated');
      }

      // Use the SendGroupMessage use case
      await ref.read(sendGroupMessageProvider)(
        groupId: widget.groupId,
        senderId: currentUserId,
        senderName: userProfile.displayName,
        content: content,
      );

      // Scroll to bottom after sending
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: AppColors.panicRed,
          ),
        );
        // Restore the message if it failed
        _controller.text = content;
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the messages stream for real-time updates
    final messagesAsync = ref.watch(groupMessagesProvider(widget.groupId));

    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.groupName, style: AppTextStyles.h2),
            Text(
              'Group Chat',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.inkFaded,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.inkBlack,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Go back to group detail
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return _EmptyMessagesPlaceholder();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  reverse: true, // Show newest messages at bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final showDate = _shouldShowDate(messages, index);
                    
                    return Column(
                      children: [
                        if (showDate)
                          _DateSeparator(date: message.timestamp),
                        _MessageBubble(
                          message: message,
                          currentUserId: ref.read(currentUserIdProvider),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.panicRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load messages',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.panicRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(groupMessagesProvider(widget.groupId)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Message input
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_isSending,
                      decoration: InputDecoration(
                        hintText: 'Message the group...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.inkFaded,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.paperWhite,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      style: AppTextStyles.bodyMedium,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    onPressed: _isSending ? null : _sendMessage,
                    color: AppColors.holyBlue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Check if we should show a date separator before this message
  bool _shouldShowDate(List<Message> messages, int index) {
    if (index == messages.length - 1) return true;
    
    final currentDate = messages[index].timestamp;
    final previousDate = messages[index + 1].timestamp;
    
    return currentDate.day != previousDate.day ||
        currentDate.month != previousDate.month ||
        currentDate.year != previousDate.year;
  }
}

/// Empty messages placeholder
class _EmptyMessagesPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.inkBlack.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.inkBlack.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to say something!',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.inkBlack.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Date separator widget
class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: AppColors.paperEdge, thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _formatDate(date),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.inkFaded,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: AppColors.paperEdge, thickness: 1),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }
}

/// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final Message message;
  final String? currentUserId;

  const _MessageBubble({
    required this.message,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == currentUserId;
    final timeFormat = DateFormat('h:mm a');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.holyBlue.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.holyBlue,
                  ),
                ),
              ),
            Text(
              message.content,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              timeFormat.format(message.timestamp),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.inkBlack.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
            if (message.flaggedForReview)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag,
                      size: 12,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Flagged for review',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.orange.shade700,
                        fontSize: 10,
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
