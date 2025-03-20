import 'cm_cmp_sdk_v3_platform_interface.dart';
import 'consent_layer_ui_config.dart';

/// A Dart class providing access to CMP SDK functionalities.
class CMPmanager {
  // The single instance of CmpSdk
  static final CMPmanager _instance = CMPmanager._internal();

  // A boolean to track if initialization has occurred
  static bool _isInitialized = false;

  // Private named constructor to prevent external instantiation.
  CMPmanager._internal() {
    _initializeOnce();
  }

  // The public static accessor for the singleton instance
  static CMPmanager get instance => _instance;

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
  @Deprecated('Use checkAndOpen() instead')
  Future<void> checkWithServerAndOpenIfNecessary() {
    return CmpSdkPlatform.instance.checkWithServerAndOpenIfNecessary();
  }

  // Check if consent is required. True when the user needs to give consent
  @Deprecated('Use checkAndOpen() instead')
  Future<bool> checkIfConsentIsRequired() {
    return CmpSdkPlatform.instance.checkIfConsentIsRequired();
  }

  /// Directly opens the consent layer UI without checking if consent is required.
  @Deprecated('Use forceOpen() instead')
  Future<void> openConsentLayer() {
    return CmpSdkPlatform.instance.openConsentLayer();
  }

  /// Directly opens the consent layer with the settings page
  @Deprecated('Use forceOpen() with the jumpToSettings parameters instead')
  Future<void> jumpToSettings() {
    return CmpSdkPlatform.instance.jumpToSettings();
  }

  /// Checks if the user has given consent for a specific vendor.
  ///
  /// [id] - The unique identifier for the vendor.
  @Deprecated('Use getStatusForVendor() instead')
  Future<bool> hasVendorConsent(String id, {bool defaultReturn = true}) {
    return CmpSdkPlatform.instance
        .hasVendorConsent(id, defaultReturn: defaultReturn);
  }

  /// Checks if the user has given consent for a specific purpose.
  ///
  /// [id] - The unique identifier for the purpose.
  @Deprecated('Use getStatusForPurpose() instead')
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
  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getAllVendorsIDs() {
    return CmpSdkPlatform.instance.getAllVendorsIDs();
  }

  /// Retrieves a list of all purposes registered with the CMP.
  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getAllPurposesIDs() {
    return CmpSdkPlatform.instance.getAllPurposesIDs();
  }

  /// Checks if the user has given general consent.
  @Deprecated('Use getUserStatus() instead')
  Future<bool> hasUserChoice() {
    return CmpSdkPlatform.instance.hasUserChoice();
  }

  /// Retrieves a list of purposes for which the user has given consent.
  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getEnabledPurposesIDs() {
    return CmpSdkPlatform.instance.getEnabledPurposesIDs();
  }

  /// Retrieves a list of vendors for which the user has given consent.
  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getEnabledVendorsIDs() {
    return CmpSdkPlatform.instance.getEnabledVendorsIDs();
  }

  /// Retrieves a list of purposes for which the user has not given consent.
  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getDisabledPurposesIDs() {
    return CmpSdkPlatform.instance.getDisabledPurposesIDs();
  }

  /// Retrieves a list of vendors for which the user has not given consent.
  @Deprecated('Use getUserStatus() instead')
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
}
