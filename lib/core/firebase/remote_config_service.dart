import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:electromart_pro/core/constants/app_constants.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await _remoteConfig.setDefaults({
      AppConstants.remoteConfigFlashSaleBanner: false,
      AppConstants.remoteConfigMinFreeDelivery: 50.0,
      AppConstants.remoteConfigMaintenanceMode: false,
      AppConstants.remoteConfigForceUpdateVersion: '1.0.0',
    });

    await _remoteConfig.fetchAndActivate();
  }

  bool get flashSaleBannerVisible =>
      _remoteConfig.getBool(AppConstants.remoteConfigFlashSaleBanner);

  double get minFreeDelivery =>
      _remoteConfig.getDouble(AppConstants.remoteConfigMinFreeDelivery);

  bool get maintenanceMode =>
      _remoteConfig.getBool(AppConstants.remoteConfigMaintenanceMode);

  String get forceUpdateVersion =>
      _remoteConfig.getString(AppConstants.remoteConfigForceUpdateVersion);

  Future<void> fetchAndActivate() async {
    await _remoteConfig.fetchAndActivate();
  }

  String getString(String key) => _remoteConfig.getString(key);

  bool getBool(String key) => _remoteConfig.getBool(key);

  int getInt(String key) => _remoteConfig.getInt(key);

  double getDouble(String key) => _remoteConfig.getDouble(key);
}
