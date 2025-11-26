import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'config/routes.dart';
import 'core/constants/route_constants.dart';
import 'providers/providers.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch authentication state
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
    return MaterialApp(
      title: 'Freedom Path',
      theme: AppTheme.journalTheme,
      debugShowCheckedModeBanner: false,
      // Navigate to login if not authenticated, otherwise use normal routes
      initialRoute: isAuthenticated ? Routes.splash : '/login',
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
