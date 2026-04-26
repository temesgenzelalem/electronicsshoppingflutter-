import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'ElectroMart Pro';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFF007AFF);
  static const Color secondaryColor = Color(0xFFFF9500);
  static const Color accentColor = Color(0xFF34C759);
  static const Color errorColor = Color(0xFFFF3B30);
  static const Color warningColor = Color(0xFFFFCC00);
  static const Color successColor = Color(0xFF34C759);

  // Text Styles
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );
  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusExtraLarge = 16.0;

  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  // Limits
  static const int maxCartItems = 50;
  static const int maxWishlistItems = 100;
  static const int maxAddresses = 5;
  static const int maxPaymentMethods = 3;
  static const int maxReviewsPerProduct = 10;

  // Pagination
  static const int productsPerPage = 20;
  static const int ordersPerPage = 10;
  static const int reviewsPerPage = 10;

  // Search
  static const int maxRecentSearches = 10;
  static const int minSearchQueryLength = 2;

  // Notifications
  static const String fcmChannelId = 'electromart_channel';
  static const String fcmChannelName = 'ElectroMart Notifications';
  static const String fcmChannelDescription = 'Notifications for orders, offers, and updates';

  // URLs
  static const String privacyPolicyUrl = 'https://electromart.com/privacy';
  static const String termsOfServiceUrl = 'https://electromart.com/terms';
  static const String supportUrl = 'https://electromart.com/support';

  // Payment
  static const double minOrderAmount = 10.0;
  static const double freeDeliveryThreshold = 50.0;
  static const double deliveryCharge = 5.0;
  static const double taxRate = 0.18; // 18% GST

  // Remote Config Keys
  static const String remoteConfigFlashSaleBanner = 'flash_sale_banner_visible';
  static const String remoteConfigMinFreeDelivery = 'min_free_delivery';
  static const String remoteConfigMaintenanceMode = 'maintenance_mode';
  static const String remoteConfigForceUpdateVersion = 'force_update_version';

  // Analytics Events
  static const String analyticsEventProductView = 'product_view';
  static const String analyticsEventAddToCart = 'add_to_cart';
  static const String analyticsEventPurchase = 'purchase';
  static const String analyticsEventSearch = 'search';

  // Error Messages
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorAuth = 'Authentication failed. Please sign in again.';
  static const String errorPayment = 'Payment failed. Please try again.';
}