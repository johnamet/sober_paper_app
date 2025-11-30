import 'package:flutter/material.dart';
import '../core/constants/route_constants.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/contacts_screen.dart';
import '../screens/reflections_screen.dart';
import '../screens/daily_reflection_screen.dart';
import '../screens/saint_of_the_day_screen.dart';
import '../screens/catholic_readings_screen.dart';
import '../screens/panic_modal.dart';
import '../screens/find_sponsor_screen.dart';
import '../screens/group_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/edit_profile_screen.dart';

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
      
      case Routes.findSponsor:
        return MaterialPageRoute(builder: (_) => FindSponsorScreen());
      
      case Routes.groupList:
        return MaterialPageRoute(builder: (_) => GroupListScreen());
      
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      
      case Routes.editProfile:
        return MaterialPageRoute(builder: (_) => EditProfileScreen());
      
      case Routes.dailyReflection:
        return MaterialPageRoute(builder: (_) => const DailyReflectionScreen());
      
      case Routes.saintOfTheDay:
        return MaterialPageRoute(builder: (_) => const SaintOfTheDayScreen());
      
      case Routes.catholicReadings:
        return MaterialPageRoute(builder: (_) => const CatholicReadingsScreen());
      
      default:
        // Default to splash screen for unknown routes
        return MaterialPageRoute(builder: (_) => SplashScreen());
    }
  }
}
