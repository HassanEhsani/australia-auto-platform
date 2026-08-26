import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../auth/presentation/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curve);

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1).animate(curve);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curve);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              const Spacer(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: SizedBox(
                        height: 320,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/onboarding/onboarding_hero_studio.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 36,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                  children: [
                    TextSpan(
                      text: 'KING ',
                      style: TextStyle(color: AppColors.accent),
                    ),
                    TextSpan(
                      text: 'AUTO',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 54,
                child: Image.asset(
                  'assets/images/branding/king_auto_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Find your next vehicle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Browse used, damaged and salvage vehicles across Australia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
