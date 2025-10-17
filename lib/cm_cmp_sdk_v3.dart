import 'cm_cmp_sdk_v3_method_channel.dart';
import 'cm_cmp_sdk_v3_platform_interface.dart';
import 'consent_layer_ui_config.dart';

/// A Dart class providing access to CMP SDK functionalities.
class CMPManager {
  static final CMPManager _instance = CMPManager._internal();
  static CMPManager get instance => _instance;
  final _methodChannel = MethodChannelCmpSdk();
  static bool _isInitialized = false;

  CMPManager._internal();

  /// Set the URL configuration and initialize the SDK
  Future<void> setUrlConfig({
    required String id,
    required String domain,
    required String appName,
    required String language,
    bool noHash = false,
  }) async {
    await _methodChannel.setUrlConfig(
      id: id,
      domain: domain,
      appName: appName,
      language: language,
      noHash: noHash,
    );

    await _methodChannel.setOnClickLinkCallback(null);

    if (!_isInitialized) {
      await _methodChannel.initialize();
      _isInitialized = true;
      await _methodChannel.checkAndOpen();
    }
  }

  /// set the WebView configuration
  Future<void> setWebViewConfig(ConsentLayerUIConfig config) async {
    await CmpSdkPlatform.instance.setWebViewConfig(config);
  }

  /// Exports the current CMP string representing the user's consent preferences.
  Future<String?> exportCMPInfo() {
    return CmpSdkPlatform.instance.exportCMPInfo();
  }

  /// Resets the CMP data, clearing all user consent preferences.
  Future<void> resetConsentManagementData() {
    return CmpSdkPlatform.instance.resetConsentManagementData();
  }

  /// Imports a CMP string, updating the user's consent preferences accordingly.
  ///
  /// [cmpString] - The CMP string to import.
  Future<bool> importCMPInfo(String cmpString) {
    return CmpSdkPlatform.instance.importCMPInfo(cmpString);
  }

  /// Sets up callback functions for various CMP events.
  void addEventListeners({
    DidReceiveConsent? didReceiveConsent,
    DidShowConsentLayer? didShowConsentLayer,
    DidCloseConsentLayer? didCloseConsentLayer,
    DidReceiveError? didReceiveError,
  }) {
    CmpSdkPlatform.instance.addEventListeners(
      didReceiveConsent: didReceiveConsent,
      didShowConsentLayer: didShowConsentLayer,
      didCloseConsentLayer: didCloseConsentLayer,
      didReceiveError: didReceiveError,
    );
  }

  /// Accepts all consents on behalf of the user.
  Future<void> acceptAll() {
    return CmpSdkPlatform.instance.acceptAll();
  }

  /// Rejects all consents on behalf of the user.
  Future<void> rejectAll() {
    return CmpSdkPlatform.instance.rejectAll();
  }

  /// Rejects the given vendors.
  Future<void> rejectVendors(List<String> vendors) {
    return CmpSdkPlatform.instance.rejectVendors(vendors);
  }

  /// Accepts the given vendors.
  Future<void> acceptVendors(List<String> vendors) {
    return CmpSdkPlatform.instance.acceptVendors(vendors);
  }

  /// Rejects the given purposes.
  Future<void> rejectPurposes(List<String> purposes) {
    return CmpSdkPlatform.instance.rejectPurposes(purposes);
  }

  /// Accepts the given purposes.
  Future<void> acceptPurposes(List<String> purposes) {
    return CmpSdkPlatform.instance.acceptPurposes(purposes);
  }

  /// Returns the current user consent status including all vendors and purposes
  Future<UserConsentStatus> getUserStatus() {
    return CmpSdkPlatform.instance.getUserStatus();
  }

  /// Returns the consent status for a specific purpose
  Future<ConsentStatus> getStatusForPurpose(String id) {
    return CmpSdkPlatform.instance.getStatusForPurpose(id);
  }

  /// Returns the consent status for a specific vendor
  Future<ConsentStatus> getStatusForVendor(String id) {
    return CmpSdkPlatform.instance.getStatusForVendor(id);
  }

  /// Returns the Google Consent Mode v2 settings map
  Future<Map<String, String>> getGoogleConsentModeStatus() {
    return CmpSdkPlatform.instance.getGoogleConsentModeStatus();
  }

  /// Sets a callback to handle URL clicks in the consent layer
  /// Return true if the URL was handled, false to let the SDK handle it
  void setOnClickLinkCallback(OnClickLinkCallback? callback) {
    CmpSdkPlatform.instance.setOnClickLinkCallback(callback);
  }

  /// Force opens the consent layer UI.
  Future<void> forceOpen({bool jumpToSettings = false}) {
    return CmpSdkPlatform.instance.forceOpen(jumpToSettings: jumpToSettings);
  }

  /// Checks consent and opens the layer if necessary.
  Future<void> checkAndOpen({bool jumpToSettings = false}) {
    return CmpSdkPlatform.instance.checkAndOpen(jumpToSettings: jumpToSettings);
  }

  /// Enables or disables automatic consent updates.
  /// 
  /// [enabled] - true to enable automatic updates, false to disable
  Future<void> setAutomaticConsentUpdatesEnabled(bool enabled) {
    return CmpSdkPlatform.instance.setAutomaticConsentUpdatesEnabled(enabled);
  }

  /// Sets the ATT (App Tracking Transparency) status for iOS.
  /// 
  /// This status will be automatically included in all subsequent consent requests
  /// as the `cmpatt` parameter. Use this to inform the CMP about the user's ATT choice.
  ///
  /// [status] - The ATT status value (0-3):
  ///   - 0: notDetermined
  ///   - 1: restricted
  ///   - 2: denied
  ///   - 3: authorized
  ///
  /// Note: This method only affects iOS. On Android, it will be ignored.
  ///
  /// Example:
  /// ```dart
  /// import 'package:app_tracking_transparency/app_tracking_transparency.dart';
  /// 
  /// final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  /// CMPManager.instance.setATTStatus(status.index);
  /// ```
  Future<void> setATTStatus(int status) {
    return CmpSdkPlatform.instance.setATTStatus(status);
  }
}
