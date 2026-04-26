import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/firebase/firebase_service.dart';
import 'package:electromart_pro/core/firebase/messaging_service.dart';
import 'package:electromart_pro/core/firebase/dynamic_links_service.dart';
import 'package:electromart_pro/core/firebase/remote_config_service.dart';
import 'package:electromart_pro/core/providers/theme_provider.dart';
import 'package:electromart_pro/features/splash/splash_screen.dart';
import 'package:electromart_pro/features/onboarding/onboarding_screen.dart';
import 'package:electromart_pro/features/auth/login_screen.dart';
import 'package:electromart_pro/features/auth/register_screen.dart';
import 'package:electromart_pro/features/auth/phone_auth_screen.dart';
import 'package:electromart_pro/features/home/home_screen.dart';
import 'package:electromart_pro/features/explore/explore_screen.dart';
import 'package:electromart_pro/features/product_detail/product_detail_screen.dart';
import 'package:electromart_pro/features/cart/cart_screen.dart';
import 'package:electromart_pro/features/wishlist/wishlist_screen.dart';
import 'package:electromart_pro/features/checkout/checkout_screen.dart';
import 'package:electromart_pro/features/orders/order_tracking_screen.dart';
import 'package:electromart_pro/features/profile/profile_screen.dart';
import 'package:electromart_pro/features/notifications/notifications_screen.dart';
import 'package:electromart_pro/features/search/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService.initialize();

  // Initialize other services
  final messagingService = MessagingService();
  await messagingService.initialize();

  final dynamicLinksService = DynamicLinksService();
  await dynamicLinksService.initialize();

  final remoteConfigService = RemoteConfigService();
  await remoteConfigService.initialize();

  runApp(
    const ProviderScope(
      child: ElectroMartApp(),
    ),
  );
}

class ElectroMartApp extends ConsumerWidget {
  const ElectroMartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'ElectroMart Pro',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/phone-auth': (context) => const PhoneAuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/explore': (context) => const ExploreScreen(),
        '/product-detail': (context) => ProductDetailScreen(
              productId: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/cart': (context) => const CartScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/order-tracking': (context) => OrderTrackingScreen(
              orderId: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/search': (context) => SearchScreen(
              initialQuery:
                  ModalRoute.of(context)!.settings.arguments as String?,
            ),
      },
    );
  }
}
