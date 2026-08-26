import 'package:flutter/material.dart';

import '../features/onboarding/presentation/onboarding_screen.dart';
import 'theme/app_theme.dart';

class KingAutoApp extends StatelessWidget {
  const KingAutoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'King Auto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const OnboardingScreen(),
    );
  }
}
