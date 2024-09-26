import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cmp_sdk_v3_method_channel.dart';
import 'consent_layer_ui_config.dart';
import 'constants/ios/att_status.dart';

typedef DidChangeATTStatus = void Function(
    int oldStatus, int newStatus, DateTime lastUpdated);
typedef DidReceiveError = void Function(String error);
typedef DidReceiveConsent = void Function(
    String consent, Map<String, dynamic> jsonObject);
typedef DidShowConsentLayer = void Function();
typedef DidCloseConsentLayer = void Function();

enum GoogleConsentType {
  analyticsStorage,
  adStorage,
  adUserData,
  adPersonalization,
}

enum GoogleConsentStatus { granted, denied }

enum CmpButtonEvent {
  unknown,
  acceptAll,
  rejectAll,
  save,
  close,
}

enum CmpErrorType {
  networkError,
  timeoutError,
  consentDataReadWriteError,
  unknownError,
}

abstract class CmpSdkPlatform extends PlatformInterface {
  /// Constructs a CmpSdkPlatform.
  CmpSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static CmpSdkPlatform _instance = MethodChannelCmpSdk();

  /// The default instance of [CmpSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelCmpSdk].
  static CmpSdkPlatform get instance => _instance;

  static set instance(CmpSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> addEventListeners({
    DidReceiveConsent? didReceiveConsent,
    DidShowConsentLayer? didShowConsentLayer,
    DidCloseConsentLayer? didCloseConsentLayer,
    DidChangeATTStatus? didChangeATTStatus,
    DidReceiveError? didReceiveError,
  });
  Future<void> initialize();
  Future<void> setUrlConfig(
      {required String id,
      required String domain,
      required String appName,
      required String language});
  Future<void> setWebViewConfig(ConsentLayerUIConfig config);
  Future<bool> hasUserChoice();
  Future<bool> hasVendorConsent(String id, {bool defaultReturn = true});
  Future<bool> hasPurposeConsent(String id, {bool defaultReturn = true});
  Future<List<dynamic>> getAllVendorsIDs();
  Future<List<dynamic>> getAllPurposesIDs();
  Future<List<dynamic>> getEnabledPurposesIDs();
  Future<List<dynamic>> getEnabledVendorsIDs();
  Future<List<dynamic>> getDisabledPurposesIDs();
  Future<List<dynamic>> getDisabledVendorsIDs();
  Future<void> checkWithServerAndOpenIfNecessary();
  Future<void> openConsentLayer();
  Future<void> jumpToSettings();
  Future<bool> checkIfConsentIsRequired();
  Future<void> acceptPurposes(List<String> purposes,
      {bool updateVendors = true});
  Future<void> rejectPurposes(List<String> purposes,
      {bool updateVendors = true});
  Future<void> acceptVendors(List<String> vendors);
  Future<void> rejectVendors(List<String> vendors);
  Future<void> acceptAll();
  Future<void> rejectAll();
  Future<bool> importCMPInfo(String cmpString);
  Future<String?> exportCMPInfo();

  Future<void> resetConsentManagementData();
  Future<void> requestATTPermission();
  Future<ATTStatus> getATTAuthorizationStatus();
}
