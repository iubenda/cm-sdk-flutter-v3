import 'dart:io';

import 'cmp_sdk_v3_platform_interface.dart';
import 'consent_layer_ui_config.dart';
import 'constants/ios/att_status.dart';

/// A Dart class providing access to CMP SDK functionalities.
class CmpSdk {
  // The single instance of CmpSdk
  static final CmpSdk _instance = CmpSdk._internal();

  // A boolean to track if initialization has occurred
  static bool _isInitialized = false;

  // Private named constructor to prevent external instantiation.
  CmpSdk._internal() {
    _initializeOnce();
  }

  // The public static accessor for the singleton instance
  static CmpSdk get instance => _instance;

  /// Ensures that CmpSdkPlatform.instance.initialize() is called only once.
  void _initializeOnce() {
    if (!_isInitialized) {
      CmpSdkPlatform.instance.initialize();
      _isInitialized = true;
    }
  }

  /// set the Url Config
  Future<void> setUrlConfig({
    required String id,
    required String domain,
    required String appName,
    required String language,
  }) async {
    await CmpSdkPlatform.instance.setUrlConfig(
        id: id, domain: domain, appName: appName, language: language);
  }

  /// set the WebView configuration
  Future<void> setWebViewConfig(ConsentLayerUIConfig config) async {
    await CmpSdkPlatform.instance.setWebViewConfig(config);
  }

  /// Opens the consent layer if consent check is required.
  ///
  /// This method checks if user consent is required and, if so, opens the consent layer UI.
  Future<void> checkWithServerAndOpenIfNecessary() {
    return CmpSdkPlatform.instance.checkWithServerAndOpenIfNecessary();
  }

  // Check if consent is required. True when the user needs to give consent
  Future<bool> checkIfConsentIsRequired() {
    return CmpSdkPlatform.instance.checkIfConsentIsRequired();
  }

  /// Directly opens the consent layer UI without checking if consent is required.
  Future<void> openConsentLayer() {
    return CmpSdkPlatform.instance.openConsentLayer();
  }

  /// Directly opens the consent layer with the settings page
  Future<void> jumpToSettings() {
    return CmpSdkPlatform.instance.jumpToSettings();
  }

  /// Checks if the user has given consent for a specific vendor.
  ///
  /// [id] - The unique identifier for the vendor.
  Future<bool> hasVendorConsent(String id, {bool defaultReturn = true}) {
    return CmpSdkPlatform.instance
        .hasVendorConsent(id, defaultReturn: defaultReturn);
  }

  /// Checks if the user has given consent for a specific purpose.
  ///
  /// [id] - The unique identifier for the purpose.
  Future<bool> hasPurposeConsent(String id, {bool defaultReturn = true}) {
    return CmpSdkPlatform.instance
        .hasPurposeConsent(id, defaultReturn: defaultReturn);
  }

  /// Exports the current CMP string representing the user's consent preferences.
  Future<String?> exportCMPInfo() {
    return CmpSdkPlatform.instance.exportCMPInfo();
  }

  /// Resets the CMP data, clearing all user consent preferences.
  Future<void> resetConsentManagementData() {
    return CmpSdkPlatform.instance.resetConsentManagementData();
  }

  /// Retrieves a list of all vendors registered with the CMP.
  Future<List<dynamic>> getAllVendorsIDs() {
    return CmpSdkPlatform.instance.getAllVendorsIDs();
  }

  /// Retrieves a list of all purposes registered with the CMP.
  Future<List<dynamic>> getAllPurposesIDs() {
    return CmpSdkPlatform.instance.getAllPurposesIDs();
  }

  /// Checks if the user has given general consent.
  Future<bool> hasUserChoice() {
    return CmpSdkPlatform.instance.hasUserChoice();
  }

  /// Retrieves a list of purposes for which the user has given consent.
  Future<List<dynamic>> getEnabledPurposesIDs() {
    return CmpSdkPlatform.instance.getEnabledPurposesIDs();
  }

  /// Retrieves a list of vendors for which the user has given consent.
  Future<List<dynamic>> getEnabledVendorsIDs() {
    return CmpSdkPlatform.instance.getEnabledVendorsIDs();
  }

  /// Retrieves a list of purposes for which the user has not given consent.
  Future<List<dynamic>> getDisabledPurposesIDs() {
    return CmpSdkPlatform.instance.getDisabledPurposesIDs();
  }

  /// Retrieves a list of vendors for which the user has not given consent.
  Future<List<dynamic>> getDisabledVendorsIDs() {
    return CmpSdkPlatform.instance.getDisabledVendorsIDs();
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
    DidChangeATTStatus? didChangeATTStatus,
  }) {
    CmpSdkPlatform.instance.addEventListeners(
      didReceiveConsent: didReceiveConsent,
      didShowConsentLayer: didShowConsentLayer,
      didCloseConsentLayer: didCloseConsentLayer,
      didReceiveError: didReceiveError,
      didChangeATTStatus: didChangeATTStatus,
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

  /// Request ATT Permission (iOS only)
  Future<void> requestATTPermission() {
    if (Platform.isIOS) {
      return CmpSdkPlatform.instance.requestATTPermission();
    } else {
      // For non-iOS platforms, return an immediately completed future.
      return Future.value();
    }
  }

  /// Get the current ATT Authorization Status (iOS only)
  Future<ATTStatus> getATTAuthorizationStatus() async {
    if (Platform.isIOS) {
      return await CmpSdkPlatform.instance.getATTAuthorizationStatus();
    } else {
      // For non-iOS platforms, return a default status (notDetermined)
      return Future.value(ATTStatus.notDetermined);
    }
  }
}
