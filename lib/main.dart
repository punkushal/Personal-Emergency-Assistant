import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/constants/app_themes.dart';
import 'package:personal_emergency_assistant/screens/home/home_screen.dart';
import 'package:personal_emergency_assistant/screens/onboarding/onboarding_screen.dart';
import 'package:personal_emergency_assistant/services/storage_service.dart';

Future<void> main() async {
  //Load environment variables
  await dotenv.load();

  //Initialize storage service
  await StorageService.instance.init();

  //Check if user has completed onboarding
  final storageService = StorageService.instance;
  final hasCompletedOnboarding = storageService.getHasCompletedOnboarding();
  runApp(
    ProviderScope(
      child: MyApp(hasCompletedOnboarding: await hasCompletedOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasCompletedOnboarding;
  const MyApp({super.key, required this.hasCompletedOnboarding});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Emergency Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: hasCompletedOnboarding ? HomeScreen() : OnboardingScreen(),
    );
  }
}
