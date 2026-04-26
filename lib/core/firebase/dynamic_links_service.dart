import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share_plus/share_plus.dart';

class DynamicLinksService {
  final FirebaseDynamicLinks _dynamicLinks = FirebaseDynamicLinks.instance;

  Future<void> initialize() async {
    // Handle dynamic links when app is opened
    final PendingDynamicLinkData? initialLink =
        await _dynamicLinks.getInitialLink();
    if (initialLink != null) {
      _handleDynamicLink(initialLink);
    }

    // Handle dynamic links when app is in background
    _dynamicLinks.onLink.listen(_handleDynamicLink);
  }

  Future<String> createProductShareLink(String productId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://electromartpro.page.link',
      link: Uri.parse('https://electromartpro.com/product/$productId'),
      androidParameters:
          const AndroidParameters(packageName: 'com.example.electromart_pro'),
      iosParameters:
          const IOSParameters(bundleId: 'com.example.electromartPro'),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check out this product on ElectroMart Pro',
        description: 'Amazing electronics at great prices',
      ),
    );

    final ShortDynamicLink shortLink =
        await _dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }

  Future<String> createReferralLink(String userId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://electromartpro.page.link',
      link: Uri.parse('https://electromartpro.com/referral/$userId'),
      androidParameters:
          const AndroidParameters(packageName: 'com.example.electromart_pro'),
      iosParameters:
          const IOSParameters(bundleId: 'com.example.electromartPro'),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Join ElectroMart Pro with my referral',
        description: 'Get discounts on your first purchase',
      ),
    );

    final ShortDynamicLink shortLink =
        await _dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }

  Future<String> createPasswordResetLink(String email) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://electromartpro.page.link',
      link: Uri.parse('https://electromartpro.com/reset-password?email=$email'),
      androidParameters:
          const AndroidParameters(packageName: 'com.example.electromart_pro'),
      iosParameters:
          const IOSParameters(bundleId: 'com.example.electromartPro'),
    );

    final ShortDynamicLink shortLink =
        await _dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }

  void shareLink(String url, String title) {
    Share.share(url, subject: title);
  }

  void _handleDynamicLink(PendingDynamicLinkData dynamicLinkData) {
    final Uri deepLink = dynamicLinkData.link;
    if (deepLink.pathSegments.contains('product')) {
      final productId = deepLink.pathSegments.last;
      // Navigate to product detail
    } else if (deepLink.pathSegments.contains('referral')) {
      final referrerId = deepLink.pathSegments.last;
      // Handle referral
    } else if (deepLink.pathSegments.contains('reset-password')) {
      final email = deepLink.queryParameters['email'];
      // Handle password reset
    }
  }
}
