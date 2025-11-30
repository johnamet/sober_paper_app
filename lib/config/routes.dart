import 'package:flutter/material.dart';
import '../core/constants/route_constants.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/contacts_screen.dart';
import '../screens/reflections_screen.dart';
import '../screens/panic_modal.dart';
import '../screens/groups/support_groups_screen.dart';
import '../screens/groups/create_group_screen.dart';
import '../screens/groups/group_detail_screen.dart';
import '../screens/groups/group_chat_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      
      case Routes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      
      case Routes.register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      
      case Routes.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      
      case Routes.calendar:
        return MaterialPageRoute(builder: (_) => CalendarScreen());
      
      case Routes.community:
        return MaterialPageRoute(builder: (_) => ContactsScreen());
      
      case Routes.resources:
        return MaterialPageRoute(builder: (_) => ReflectionsScreen());
      
      case Routes.panic:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: PanicModal(),
          ),
          fullscreenDialog: true,
        );
      
      case Routes.groupList:
        return MaterialPageRoute(builder: (_) => const SupportGroupsScreen());
      
      case '/groups/create':
        return MaterialPageRoute(builder: (_) => const CreateGroupScreen());
      
      case Routes.groupChat:
        // Extract groupId and groupName from arguments
        final args = settings.arguments as Map<String, String>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => GroupChatScreen(
              groupId: args['groupId']!,
              groupName: args['groupName']!,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => SplashScreen());
      
      default:
        // Handle group detail route with dynamic groupId
        if (settings.name?.startsWith('/community/groups/') == true) {
          final groupId = settings.name!.split('/').last;
          if (groupId.isNotEmpty && groupId != 'chat') {
            return MaterialPageRoute(
              builder: (_) => GroupDetailScreen(groupId: groupId),
            );
          }
        }
        // Default to splash screen for unknown routes
        return MaterialPageRoute(builder: (_) => SplashScreen());
    }
  }
}
