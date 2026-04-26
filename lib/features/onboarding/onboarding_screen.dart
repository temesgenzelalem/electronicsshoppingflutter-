import 'package:flutter/material.dart';
import 'package:electromart_pro/core/constants/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Welcome to ElectroMart',
      'description': 'Discover the latest electronics and gadgets at unbeatable prices.',
      'image': 'assets/images/onboarding1.png', // You'll need to add these images
    },
    {
      'title': 'Quality Products',
      'description': 'Shop from trusted brands with warranty and quality assurance.',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Fast Delivery',
      'description': 'Get your orders delivered quickly and securely to your doorstep.',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationDurationMedium,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    // TODO: Mark onboarding as completed and navigate to login
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return _buildPage(_onboardingData[index]);
              },
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder for image
          Container(
            height: 200,
            width: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 50),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Text(
            data['title']!,
            style: AppConstants.headline1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            data['description']!,
            style: AppConstants.bodyText1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => _buildDot(index),
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              child: Text(_currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next'),
            ),
          ),
          TextButton(
            onPressed: _completeOnboarding,
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppConstants.primaryColor : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}