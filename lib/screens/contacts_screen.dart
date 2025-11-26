import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'chat_screen.dart';

/// Contacts/Messages screen showing list of conversations
/// 
/// This is a simple implementation showing potential chat contacts.
/// In a full implementation, this would show:
/// - Recent conversations
/// - Unread message counts
/// - Last message preview
/// - Online status indicators
class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with real contacts from community members, sponsors, etc.
    final mockContacts = [
      {'id': 'sponsor123', 'name': 'My Sponsor', 'role': 'Sponsor'},
      {'id': 'buddy456', 'name': 'Recovery Buddy', 'role': 'Peer Support'},
      {'id': 'volunteer789', 'name': 'Crisis Volunteer', 'role': 'Volunteer'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: AppTextStyles.h2),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.inkBlack,
      ),
      body: ListView.builder(
        itemCount: mockContacts.length,
        itemBuilder: (context, index) {
          final contact = mockContacts[index];
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.inkBlack.withOpacity(0.1),
              child: Text(
                contact['name']![0],
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.inkBlack,
                ),
              ),
            ),
            title: Text(
              contact['name']!,
              style: AppTextStyles.h3,
            ),
            subtitle: Text(
              contact['role']!,
              style: AppTextStyles.caption,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    recipientId: contact['id']!,
                    recipientName: contact['name']!,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show dialog to search for users to message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User search not yet implemented'),
            ),
          );
        },
        backgroundColor: AppColors.inkBlack,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
