import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'models/catholic_reading_model.dart';
import 'models/catholic_reflection_model.dart';
import 'models/saint_of_the_day_model.dart';
import 'data/repositories/catholic_reading_repository.dart';
import 'data/repositories/catholic_reflection_repository.dart';
import 'data/repositories/saint_of_the_day_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters for Catholic readings
  Hive.registerAdapter(ReadingAdapter());
  Hive.registerAdapter(DailyCatholicReadingAdapter());
  Hive.registerAdapter(MassMediaAdapter());
  Hive.registerAdapter(MediaTypeAdapter());
  
  // Register Hive adapter for Catholic reflections
  Hive.registerAdapter(DailyReflectionAdapter());
  
  // Register Hive adapter for Saint of the Day
  Hive.registerAdapter(SaintOfTheDayAdapter());
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase Service (Firestore & Auth config)
  await FirebaseService.instance.initialize();
  
  // Initialize Notification Service
  await NotificationService.instance.initialize();
  
  // Initialize and clean up Catholic reading cache
  final catholicReadingRepo = CatholicReadingRepository();
  await catholicReadingRepo.initialize();
  await catholicReadingRepo.clearOldCache(); // Clean up old entries
  
  // Initialize and clean up Catholic reflection cache
  final catholicReflectionRepo = CatholicReflectionRepository();
  await catholicReflectionRepo.initialize();
  await catholicReflectionRepo.clearOldCache(); // Clean up old entries
  
  // Initialize Saint of the Day repository
  final saintRepo = SaintOfTheDayRepository();
  await saintRepo.init();
  
  runApp(const ProviderScope(child: MyApp()));
}

