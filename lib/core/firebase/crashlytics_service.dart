import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static Future<void> recordError(dynamic exception, StackTrace? stackTrace,
      {String? reason}) async {
    await FirebaseCrashlytics.instance.recordError(
      exception,
      stackTrace,
      reason: reason,
    );
  }

  static Future<void> recordFlutterError(FlutterErrorDetails details) async {
    await FirebaseCrashlytics.instance.recordFlutterError(details);
  }

  static Future<void> log(String message) async {
    await FirebaseCrashlytics.instance.log(message);
  }

  static Future<void> setUserIdentifier(String identifier) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(identifier);
  }

  static Future<void> setCustomKey(String key, Object value) async {
    await FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  static Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
  }
}
