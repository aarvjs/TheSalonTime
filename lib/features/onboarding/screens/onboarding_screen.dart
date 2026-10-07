import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../models/onboarding_model.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingModel> _pages = const [
    OnboardingModel(
      title: 'Discover Your\nPerfect Salon',
      description: 'Find trusted salons and talented professionals around you.',
      imagePath: AssetConstants.onboarding1,
    ),
    OnboardingModel(
      title: 'Book With\nConfidence',
      description: 'Choose your service, select your time and book your appointment effortlessly.',
      imagePath: AssetConstants.onboarding2,
    ),
    OnboardingModel(
      title: 'Salon Services,\nYour Way',
      description: 'Visit the salon or enjoy professional services from the comfort of your home.',
      imagePath: AssetConstants.onboarding3,
    ),
  ];

  void _onNextPressed() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToChooseRole();
    }
  }

  void _onBackPressed() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToChooseRole() {
    Navigator.pushReplacementNamed(context, AppRoutes.chooseRole);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return OnboardingPage(
            model: _pages[index],
            pageIndex: index,
            totalPages: _pages.length,
            onNext: _onNextPressed,
            onBack: _onBackPressed,
            onSkip: _navigateToChooseRole,
          );
        },
      ),
    );
  }
}
