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

  /// Sets up callbacks for consent events.
  @override
  Future<void> addEventListeners({
    DidShowConsentLayer? didShowConsentLayer,
    DidCloseConsentLayer? didCloseConsentLayer,
    DidReceiveConsent? didReceiveConsent,
    DidReceiveError? didReceiveError,
  }) async {
    this.didShowConsentLayer = didShowConsentLayer;
    this.didCloseConsentLayer = didCloseConsentLayer;
    this.didReceiveConsent = didReceiveConsent;
    this.didReceiveError = didReceiveError;

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
  Future<void> setUrlConfig(
      {required String id,
      required String domain,
      required String appName,
      required String language,
      String? jsonConfig,
      bool noHash = false,
      int? webViewConnectionTimeoutMillis}) async {
    await methodChannel.invokeMethod('setUrlConfig', {
      'id': id,
      'domain': domain,
      'appName': appName,
      'language': language,
      'jsonConfig': jsonConfig,
      'noHash': noHash,
      if (webViewConnectionTimeoutMillis != null)
        'webViewConnectionTimeoutMillis': webViewConnectionTimeoutMillis,
    });
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
  Future<void> forceOpen({bool jumpToSettings = false}) {
    return methodChannel.invokeMethod('forceOpen', {'jumpToSettings': jumpToSettings});
  }

  @override
  Future<void> checkAndOpen({bool jumpToSettings = false}) {
    return methodChannel.invokeMethod('checkAndOpen', {'jumpToSettings': jumpToSettings});
  }

  OnClickLinkCallback? _onClickLinkCallback;

  @override
  Future<UserConsentStatus> getUserStatus() async {
    try {
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('getUserStatus');

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
      throw Exception('Failed to get user status: $e');
    }
  }

  ConsentStatus _parseConsentStatus(dynamic value) {
    if (value is int && value >= 0 && value < ConsentStatus.values.length) {
      return ConsentStatus.values[value];
    }

    if (value is String) {
      switch(value.toLowerCase()) {
        case 'granted': return ConsentStatus.granted;
        case 'denied': return ConsentStatus.denied;
        default: return ConsentStatus.choiceDoesntExist;
      }
    }

    return ConsentStatus.choiceDoesntExist;
  }

  UserChoiceStatus _parseUserChoiceStatus(dynamic value) {
    if (value is int && value >= 0 && value < UserChoiceStatus.values.length) {
      return UserChoiceStatus.values[value];
    }

    if (value is String) {
      switch(value.toLowerCase()) {
        case 'choiceexists': return UserChoiceStatus.choiceExists;
        case 'requiresupdate': return UserChoiceStatus.requiresUpdate;
        default: return UserChoiceStatus.choiceDoesntExist;
      }
    }

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

// In cm_cmp_sdk_v3_method_channel.dart

  @override
  Future<void> setOnClickLinkCallback(OnClickLinkCallback? callback) async {
    _onClickLinkCallback = callback;

    if (callback == null) {
      // Restore default handler; do not register with native when no callback is provided.
      methodChannel.setMethodCallHandler(_handleMethodCall);
      return;
    }

    methodChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onClickLink') {
        if (_onClickLinkCallback != null && call.arguments is Map<dynamic, dynamic>) {
          final args = call.arguments as Map<dynamic, dynamic>;
          final url = args['url'] as String;
          try {
            final handled = _onClickLinkCallback?.call(url) ?? false;
            return handled;
          } catch (_) {
            return false;
          }
        }
        return false;
      } else {
        await _handleMethodCall(call);
        return null;
      }
    });

    try {
      await methodChannel.invokeMethod('setOnClickLinkCallback');
    } catch (_) {}
  }

  @override
  Future<void> setAutomaticConsentUpdatesEnabled(bool enabled) async {
    await methodChannel.invokeMethod('setAutomaticConsentUpdatesEnabled', {'enabled': enabled});
  }

  @override
  Future<void> setATTStatus(int status) async {
    await methodChannel.invokeMethod('setATTStatus', {'status': status});
  }

  @override
  Future<bool> isConsentRequired() async {
    final result = await methodChannel.invokeMethod<bool>('isConsentRequired');
    return result ?? false;
  }
}
