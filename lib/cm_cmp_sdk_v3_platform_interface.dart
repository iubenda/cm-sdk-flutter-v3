import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cm_cmp_sdk_v3_method_channel.dart';
import 'consent_layer_ui_config.dart';

typedef DidChangeATTStatus = void Function(
    int oldStatus, int newStatus, DateTime lastUpdated);
typedef DidReceiveError = void Function(String error);
typedef DidReceiveConsent = void Function(
    String consent,
    Map<String, dynamic> jsonObject
    );
typedef DidShowConsentLayer = void Function();
typedef DidCloseConsentLayer = void Function();

typedef OnClickLinkCallback = bool Function(String url);

enum ConsentStatus {
  granted,
  denied,
  choiceDoesntExist
}

enum UserChoiceStatus {
  choiceExists,
  choiceDoesntExist,
  requiresUpdate
}

class UserConsentStatus {
  final UserChoiceStatus hasUserChoice;
  final Map<String, ConsentStatus> vendors;
  final Map<String, ConsentStatus> purposes;
  final String tcf;
  final String addtlConsent;
  final String regulation;

  UserConsentStatus({
    required this.hasUserChoice,
    required this.vendors,
    required this.purposes,
    required this.tcf,
    required this.addtlConsent,
    required this.regulation,
  });

  factory UserConsentStatus.fromJson(Map<dynamic, dynamic> json) {
    return UserConsentStatus(
      hasUserChoice: UserChoiceStatus.values[json['hasUserChoice'] as int],
      vendors: (json['vendors'] as Map<dynamic, dynamic>).map(
            (key, value) => MapEntry(
          key.toString(),
          ConsentStatus.values[value as int],
        ),
      ),
      purposes: (json['purposes'] as Map<dynamic, dynamic>).map(
            (key, value) => MapEntry(
          key.toString(),
          ConsentStatus.values[value as int],
        ),
      ),
      tcf: json['tcf']?.toString() ?? '',
      addtlConsent: json['addtlConsent']?.toString() ?? '',
      regulation: json['regulation']?.toString() ?? '',
    );
  }
}

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

  @Deprecated('Use getUserStatus() instead')
  Future<bool> hasUserChoice();

  @Deprecated('Use getStatusForVendor() instead')
  Future<bool> hasVendorConsent(String id, {bool defaultReturn = true});

  @Deprecated('Use getStatusForPurpose() instead')
  Future<bool> hasPurposeConsent(String id, {bool defaultReturn = true});

  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getAllVendorsIDs();

  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getAllPurposesIDs();

  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getEnabledPurposesIDs();

  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getEnabledVendorsIDs();

  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getDisabledPurposesIDs();

  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getDisabledVendorsIDs();

  @Deprecated('Use checkAndOpen() instead')
  Future<void> checkWithServerAndOpenIfNecessary();

  @Deprecated('Use forceOpen() instead')
  Future<void> openConsentLayer();
  Future<void> forceOpen({bool jumpToSettings = false});

  Future<void> checkAndOpen({bool jumpToSettings = false});

  Future<void> jumpToSettings();

  @Deprecated('Use checkAndOpen() instead')
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

  Future<UserConsentStatus> getUserStatus();
  Future<ConsentStatus> getStatusForPurpose(String id);
  Future<ConsentStatus> getStatusForVendor(String id);
  Future<Map<String, String>> getGoogleConsentModeStatus();
  Future<void> setOnClickLinkCallback(OnClickLinkCallback? callback);
}
