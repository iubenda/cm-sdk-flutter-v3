import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cm_cmp_sdk_v3_platform_interface.dart';
import 'consent_layer_ui_config.dart';

/// An implementation of [CmpSdkPlatform] that communicates with native code
/// through Flutter method channels for managing consent.
class MethodChannelCmpSdk extends CmpSdkPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('cm_cmp_sdk_v3');

  // Callbacks for various consent events.
  DidShowConsentLayer? didShowConsentLayer;
  DidCloseConsentLayer? didCloseConsentLayer;
  DidReceiveConsent? didReceiveConsent;
  DidReceiveError? didReceiveError;
  DidChangeATTStatus? didChangeATTStatus;

  /// Opens the consent layer if consent is required and hasn't been given yet.
  @override
  @Deprecated('Use checkAndOpen() instead')
  Future<void> checkWithServerAndOpenIfNecessary() async {
    await methodChannel.invokeMethod('checkWithServerAndOpenIfNecessary');
  }

  /// Opens the consent layer.
  @override
  @Deprecated('Use forceOpen() instead')
  Future<void> openConsentLayer() async {
    await methodChannel.invokeMethod('openConsentLayer');
  }

  /// Opens the consent layer.
  @override
  @Deprecated('Use forceOpen() with the jumpToSettings parameters instead')
  Future<void> jumpToSettings() async {
    await methodChannel.invokeMethod('jumpToSettings');
  }

  /// Checks if there is consent for the specified vendor ID.
  @override
  @Deprecated('Use getStatusForVendor() instead')
  Future<bool> hasVendorConsent(String id, {bool defaultReturn = true}) async {
    final result =
        await methodChannel.invokeMethod<bool>('hasVendorConsent', {'id': id});
    return result ?? false;
  }

  /// Checks if there is consent for the specified purpose ID.
  @override
  @Deprecated('Use getStatusForPurpose() instead')
  Future<bool> hasPurposeConsent(String id, {bool defaultReturn = true}) async {
    final result =
        await methodChannel.invokeMethod<bool>('hasPurposeConsent', {'id': id});
    return result ?? false;
  }

  /// Exports the current CMP string.
  @override
  Future<String?> exportCMPInfo() async {
    final cmpString = await methodChannel.invokeMethod<String>('exportCMPInfo');
    return cmpString;
  }

  /// Resets the consent data.
  @override
  Future<void> resetConsentManagementData() async {
    await methodChannel.invokeMethod('resetConsentManagementData');
  }

  /// Retrieves a list of all vendors.
  @override
  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getAllVendorsIDs() async {
    final vendors =
        await methodChannel.invokeListMethod<dynamic>('getAllVendorsIDs');
    return vendors ?? [];
  }

  /// Retrieves a list of all purposes.
  @override
  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getAllPurposesIDs() async {
    final purposes =
        await methodChannel.invokeListMethod<dynamic>('getAllPurposesIDs');
    return purposes ?? [];
  }

  /// Checks if consent has been given.
  @override
  @Deprecated('Use getUserStatus() instead')
  Future<bool> hasUserChoice() async {
    final result = await methodChannel.invokeMethod<bool>('hasUserChoice');
    return result ?? false;
  }

  /// Retrieves a list of enabled purposes.
  @override
  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getEnabledPurposesIDs() async {
    final purposes =
        await methodChannel.invokeListMethod<dynamic>('getEnabledPurposesIDs');
    return purposes ?? [];
  }

  /// Retrieves a list of enabled vendors.
  @override
  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getEnabledVendorsIDs() async {
    final vendors =
        await methodChannel.invokeListMethod<dynamic>('getEnabledVendorsIDs');
    return vendors ?? [];
  }

  /// Retrieves a list of disabled purposes.
  @override
  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getDisabledPurposesIDs() async {
    final purposes =
        await methodChannel.invokeListMethod<dynamic>('getDisabledPurposesIDs');
    return purposes ?? [];
  }

  /// Retrieves a list of disabled vendors.
  @override
  @Deprecated('Use getUserStatus() instead')
  Future<List<dynamic>> getDisabledVendorsIDs() async {
    final vendors =
        await methodChannel.invokeListMethod<dynamic>('getDisabledVendorsIDs');
    return vendors ?? [];
  }

  /// Sets up callbacks for consent events.
  @override
  Future<void> addEventListeners({
    DidShowConsentLayer? didShowConsentLayer,
    DidCloseConsentLayer? didCloseConsentLayer,
    DidReceiveConsent? didReceiveConsent,
    DidReceiveError? didReceiveError,
    DidChangeATTStatus? didChangeATTStatus,
  }) async {
    this.didShowConsentLayer = didShowConsentLayer;
    this.didCloseConsentLayer = didCloseConsentLayer;
    this.didReceiveConsent = didReceiveConsent;
    this.didReceiveError = didReceiveError;
    this.didChangeATTStatus = didChangeATTStatus;

    // Notify native side to set up callbacks
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handles method calls from the native platform.
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'didShowConsentLayer':
        didShowConsentLayer?.call();
        break;
      case 'didCloseConsentLayer':
        didCloseConsentLayer?.call();
        break;
      case 'didReceiveConsent':
        final args = call.arguments as Map<dynamic, dynamic>;
        final consent = args['consent'] as String;
        final jsonObject = Map<String, dynamic>.from(args['jsonObject'] as Map);
        didReceiveConsent?.call(consent, jsonObject);
        break;
      case 'didReceiveError':
        if (call.arguments is Map) {
          final args = call.arguments as Map<dynamic, dynamic>;
          final String error = args['error'] as String;
          didReceiveError?.call(error);
        }
        break;
      case 'didChangeATTStatus':
        if (call.arguments is Map) {
          final args = call.arguments as Map<dynamic, dynamic>;
          final oldStatus = args['oldStatus'] as int;
          final newStatus = args['newStatus'] as int;
          final lastUpdated = args['lastUpdated'] as DateTime;
          didChangeATTStatus?.call(oldStatus, newStatus, lastUpdated);
        }
        break;
      default:
        if (kDebugMode) {
          print('Unknown method called on CMP SDK plugin');
        }
    }
  }

  /// Imports a CMP string.
  @override
  Future<bool> importCMPInfo(String cmpString) async {
    return await methodChannel
        .invokeMethod('importCMPInfo', {'cmpString': cmpString});
  }

  /// Accepts all consents.
  @override
  Future<void> acceptAll() async {
    await methodChannel.invokeMethod('acceptAll');
  }

  /// Rejects all consents.
  @override
  Future<void> rejectAll() async {
    await methodChannel.invokeMethod('rejectAll');
  }

  @override
  Future<void> acceptPurposes(List<String> purposes,
      {bool updateVendors = true}) async {
    await methodChannel.invokeMethod('acceptPurposes',
        {'purposes': purposes, 'updateVendors': updateVendors});
  }

  @override
  Future<void> acceptVendors(List<String> vendors) async {
    await methodChannel.invokeMethod('acceptVendors', {'vendors': vendors});
  }

  @override
  Future<void> rejectPurposes(List<String> purposes,
      {bool updateVendors = true}) async {
    await methodChannel.invokeMethod('rejectPurposes',
        {'purposes': purposes, 'updateVendors': updateVendors});
  }

  @override
  Future<void> rejectVendors(List<String> vendors) async {
    await methodChannel.invokeMethod('rejectVendors', {'vendors': vendors});
  }

  @override
  @Deprecated('Use checkAndOpen() instead')
  Future<bool> checkIfConsentIsRequired() async {
    return await methodChannel.invokeMethod('checkIfConsentIsRequired');
  }

  @override
  Future<void> setUrlConfig(
      {required String id,
      required String domain,
      required String appName,
      required String language}) async {
    await methodChannel.invokeMethod('setUrlConfig',
        {'id': id, 'domain': domain, 'appName': appName, 'language': language});
  }

  @override
  Future<void> setWebViewConfig(ConsentLayerUIConfig config) async {
    await methodChannel.invokeMethod('setWebViewConfig', config.toMap());
  }

  @override
  Future<void> initialize() async {
    await methodChannel.invokeMethod('initialize');
  }

  // Methods added on v3.1.0
  @override
  Future<void> forceOpen({bool jumpToSettings = false}) async {
    await methodChannel.invokeMethod('forceOpen', {'jumpToSettings': jumpToSettings});
  }

  @override
  Future<void> checkAndOpen({bool jumpToSettings = false}) async {
    await methodChannel.invokeMethod('checkAndOpen', {'jumpToSettings': jumpToSettings});
  }

  OnClickLinkCallback? _onClickLinkCallback;

  @override
  Future<UserConsentStatus> getUserStatus() async {
    try {
      print('Entered method channel');
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('getUserStatus');
      print('Raw getUserStatus response from method channel: $result');

      final vendors = (result?['vendors'] as Map<dynamic, dynamic>?)?.map(
            (key, value) => MapEntry(key.toString(), _parseConsentStatus(value)),
      ) ?? {};

      final purposes = (result?['purposes'] as Map<dynamic, dynamic>?)?.map(
            (key, value) => MapEntry(key.toString(), _parseConsentStatus(value)),
      ) ?? {};

      return UserConsentStatus(
        hasUserChoice: _parseUserChoiceStatus(result?['hasUserChoice']),
        vendors: vendors,
        purposes: purposes,
        tcf: result?['tcf']?.toString() ?? '',
        addtlConsent: result?['addtlConsent']?.toString() ?? '',
        regulation: result?['regulation']?.toString() ?? '',
      );
    } catch (e) {
      print(e);
      throw Exception('Failed to get user status: $e');
    }
  }

  ConsentStatus _parseConsentStatus(dynamic value) {
    // Handle integer value (proper enum ordinal)
    if (value is int && value >= 0 && value < ConsentStatus.values.length) {
      return ConsentStatus.values[value];
    }

    // Handle string value (enum name)
    if (value is String) {
      switch(value.toLowerCase()) {
        case 'granted': return ConsentStatus.granted;
        case 'denied': return ConsentStatus.denied;
        default: return ConsentStatus.choiceDoesntExist;
      }
    }

    print('Unknown consent status format: $value (${value.runtimeType})');
    // Default fallback
    return ConsentStatus.choiceDoesntExist;
  }

  UserChoiceStatus _parseUserChoiceStatus(dynamic value) {
    // Handle integer value
    if (value is int && value >= 0 && value < UserChoiceStatus.values.length) {
      return UserChoiceStatus.values[value];
    }

    // Handle string value
    if (value is String) {
      switch(value.toLowerCase()) {
        case 'choiceexists': return UserChoiceStatus.choiceExists;
        case 'requiresupdate': return UserChoiceStatus.requiresUpdate;
        default: return UserChoiceStatus.choiceDoesntExist;
      }
    }

    print('Unknown user choice status format: $value (${value.runtimeType})');
    // Default fallback
    return UserChoiceStatus.choiceDoesntExist;
  }

  @override
  Future<ConsentStatus> getStatusForPurpose(String id) async {
    final result = await methodChannel.invokeMethod<int>('getStatusForPurpose', {'id': id});
    return ConsentStatus.values[result!];
  }

  @override
  Future<ConsentStatus> getStatusForVendor(String id) async {
    final result = await methodChannel.invokeMethod<int>('getStatusForVendor', {'id': id});
    return ConsentStatus.values[result!];
  }

  @override
  Future<Map<String, String>> getGoogleConsentModeStatus() async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('getGoogleConsentModeStatus');
    return Map<String, String>.from(result!);
  }

  @override
  Future<void> setOnClickLinkCallback(OnClickLinkCallback? callback) async {
    _onClickLinkCallback = callback;
    // Register platform channel method handler if not already done
    if (callback != null) {
      methodChannel.setMethodCallHandler((call) async {
        if (call.method == 'onClickLink') {
          final url = call.arguments as String;
          return _onClickLinkCallback?.call(url) ?? false;
        }
        return null;
      });
    }
  }
}
