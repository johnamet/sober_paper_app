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
      
      default:
        // Default to splash screen for unknown routes
        return MaterialPageRoute(builder: (_) => SplashScreen());
    }
  }
}
