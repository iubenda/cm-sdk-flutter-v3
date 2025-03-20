import 'package:cm_cmp_sdk_v3/cm_cmp_sdk_v3_method_channel.dart';
import 'package:cm_cmp_sdk_v3/cm_cmp_sdk_v3_platform_interface.dart';
import 'package:cm_cmp_sdk_v3/consent_layer_ui_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCmpSdkPlatform
    with MockPlatformInterfaceMixin
    implements CmpSdkPlatform {
  @override
  Future<void> acceptAll() {
    throw UnimplementedError();
  }

  @override
  Future<void> acceptPurposes(List<String> purposes,
      {bool updateVendors = true}) async {}

  @override
  Future<void> acceptVendors(List<String> vendors) {
    throw UnimplementedError();
  }

  @override
  Future<void> addEventListeners(
      {DidReceiveConsent? didReceiveConsent,
      DidShowConsentLayer? didShowConsentLayer,
      DidCloseConsentLayer? didCloseConsentLayer,
      DidChangeATTStatus? didChangeATTStatus,
      DidReceiveError? didReceiveError}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> checkIfConsentIsRequired() {
    throw UnimplementedError();
  }

  @override
  Future<void> checkWithServerAndOpenIfNecessary() {
    throw UnimplementedError();
  }

  @override
  Future<String?> exportCMPInfo() {
    throw UnimplementedError();
  }

  @override
  Future<List> getAllPurposesIDs() {
    throw UnimplementedError();
  }

  @override
  Future<List> getAllVendorsIDs() {
    throw UnimplementedError();
  }

  @override
  Future<List> getDisabledPurposesIDs() {
    throw UnimplementedError();
  }

  @override
  Future<List> getDisabledVendorsIDs() {
    throw UnimplementedError();
  }

  @override
  Future<List> getEnabledPurposesIDs() {
    throw UnimplementedError();
  }

  @override
  Future<List> getEnabledVendorsIDs() {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasPurposeConsent(String id, {bool defaultReturn = true}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasUserChoice() {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasVendorConsent(String id, {bool defaultReturn = true}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> importCMPInfo(String cmpString) {
    throw UnimplementedError();
  }

  @override
  Future<void> initialize() {
    throw UnimplementedError();
  }

  @override
  Future<void> jumpToSettings() {
    throw UnimplementedError();
  }

  @override
  Future<void> openConsentLayer() {
    throw UnimplementedError();
  }

  @override
  Future<void> rejectAll() {
    throw UnimplementedError();
  }

  @override
  Future<void> rejectPurposes(List<String> purposes,
      {bool updateVendors = true}) {
    throw UnimplementedError();
  }

  @override
  Future<void> rejectVendors(List<String> vendors) {
    throw UnimplementedError();
  }

  @override
  Future<void> resetConsentManagementData() {
    throw UnimplementedError();
  }

  @override
  Future<void> setUrlConfig(
      {required String id,
      required String domain,
      required String appName,
      required String language}) {
    throw UnimplementedError();
  }

  @override
  Future<void> setWebViewConfig(ConsentLayerUIConfig config) {
    throw UnimplementedError();
  }

  @override
  Future<void> checkAndOpen({bool jumpToSettings = false}) {
    // TODO: implement checkAndOpen
    throw UnimplementedError();
  }

  @override
  Future<void> forceOpen({bool jumpToSettings = false}) {
    // TODO: implement forceOpen
    throw UnimplementedError();
  }

  @override
  Future<Map<String, String>> getGoogleConsentModeStatus() {
    // TODO: implement getGoogleConsentModeStatus
    throw UnimplementedError();
  }

  @override
  Future<ConsentStatus> getStatusForPurpose(String id) {
    // TODO: implement getStatusForPurpose
    throw UnimplementedError();
  }

  @override
  Future<ConsentStatus> getStatusForVendor(String id) {
    // TODO: implement getStatusForVendor
    throw UnimplementedError();
  }

  @override
  Future<UserConsentStatus> getUserStatus() {
    // TODO: implement getUserStatus
    throw UnimplementedError();
  }

  @override
  Future<void> setOnClickLinkCallback(OnClickLinkCallback? callback) {
    // TODO: implement setOnClickLinkCallback
    throw UnimplementedError();
  }
}

void main() {
  final CmpSdkPlatform initialPlatform = CmpSdkPlatform.instance;

  test('$MethodChannelCmpSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCmpSdk>());
  });
}
