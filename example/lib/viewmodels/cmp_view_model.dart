import 'package:cmp_sdk_v3/consent_layer_ui_config.dart';
import 'package:flutter/foundation.dart';
import 'package:cmp_sdk_v3/cmp_sdk_v3.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CmpViewModel extends ChangeNotifier {
  late CmpSdk _cmpSdkPlugin;
  String _consentStatus = '';
  String _callbackLogs = '';
  String _cmpString = '';
  String _idString = '1';

  String get consentStatus => _consentStatus;
  String get callbackLogs => _callbackLogs;
  String get cmpString => _cmpString;
  String get idString => _idString;

  void setCmpString(String value) {
    _cmpString = value;
    notifyListeners();
  }

  void setIdString(String value) {
    _idString = value;
    notifyListeners();
  }

  void initCmp() async {
    try {
      _cmpSdkPlugin = CmpSdk.instance;
      await _cmpSdkPlugin.setUrlConfig(
        appName: "Test",
        id: "09cb5dca91e6b",
        language: "de",
        domain: "delivery.consentmanager.net",
      );
      addEventListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing CMP: $e");
      }
    }
  }

  void addEventListeners() {
    _cmpSdkPlugin.addEventListeners(didShowConsentLayer: () {
      logCallback('Consent layer opened');
    }, didCloseConsentLayer: () {
      logCallback('Consent layer closed');
    }, didReceiveError: (error) {
      logCallback('Consent layer error $error');
    }, didReceiveConsent: (consent, jsonObject) {
      logCallback('Consent Received: $consent - $jsonObject');
    }, didChangeATTStatus: (oldStatus, newStatus, last) {
      logCallback('ATT changed: $oldStatus , $newStatus, $last');
    });
  }

  Future<void> setWebViewConfig(ConsentLayerUIConfig config) async {
    await _cmpSdkPlugin.setWebViewConfig(config);
    notifyListeners();
  }

  void logCallback(String message) {
    _callbackLogs += "$message\n";
    notifyListeners();
  }

  void acceptAll() async {
    await _cmpSdkPlugin.acceptAll();
    Fluttertoast.showToast(msg: 'Accepted Consent by acceptAll API');
  }

  void rejectAll() async {
    await _cmpSdkPlugin.rejectAll();
    Fluttertoast.showToast(msg: 'Rejected Consent by rejectAll API');
  }

  void jumpToSettings() async {
    await _cmpSdkPlugin.jumpToSettings();
    notifyListeners();
  }

  void disableVendors() async {
    if (_idString.isEmpty) {
      Fluttertoast.showToast(msg: 'ID is empty');
      return;
    }
    await _cmpSdkPlugin.rejectVendors([_idString]);
    Fluttertoast.showToast(msg: 'disabled Vendor');
    notifyListeners();
  }

  void enableVendors() async {
    if (_idString.isEmpty) {
      Fluttertoast.showToast(msg: 'ID is empty');
      return;
    }
    await _cmpSdkPlugin.acceptVendors([_idString]);
    Fluttertoast.showToast(msg: 'enabled Vendor');
    notifyListeners();
  }

  void disablePurposes() async {
    if (_idString.isEmpty) {
      Fluttertoast.showToast(msg: 'ID is empty');
      return;
    }
    await _cmpSdkPlugin.rejectPurposes([_idString]);
    Fluttertoast.showToast(msg: 'disabled Purpose');
    notifyListeners();
  }

  void enablePurposes() async {
    if (_idString.isEmpty) {
      Fluttertoast.showToast(msg: 'ID is empty');
      return;
    }
    await _cmpSdkPlugin.acceptPurposes([_idString]);
    Fluttertoast.showToast(msg: 'enabled Purpose');
    notifyListeners();
  }

  void checkWithServerAndOpenIfNecessary() async {
    await _cmpSdkPlugin.checkWithServerAndOpenIfNecessary();
    notifyListeners();
  }

  Future<bool> checkIfConsentIsRequired() async {
    return await _cmpSdkPlugin.checkIfConsentIsRequired();
  }

  void resetConsent() async {
    await _cmpSdkPlugin.resetConsentManagementData();
    Fluttertoast.showToast(msg: 'Reset consent data');
    notifyListeners();
  }

  void getStatus() async {
    Future<String> fetchStatus(
        String name, Future<dynamic> Function() method) async {
      try {
        final result = await method();
        return '$name: ${result.toString()}';
      } catch (err) {
        if (kDebugMode) {
          print(err);
        }
        return '$name: Error';
      }
    }

    final statusFutures = [
      fetchStatus('Export CmpString', _cmpSdkPlugin.exportCMPInfo),
      fetchStatus('Has User Choice', _cmpSdkPlugin.hasUserChoice),
      fetchStatus('All Vendors', _cmpSdkPlugin.getAllVendorsIDs),
      fetchStatus('All Purposes', _cmpSdkPlugin.getAllPurposesIDs),
      fetchStatus('Enabled Vendors', _cmpSdkPlugin.getEnabledVendorsIDs),
      fetchStatus('Enabled Purposes', _cmpSdkPlugin.getEnabledPurposesIDs),
      fetchStatus('Disabled Vendors', _cmpSdkPlugin.getDisabledVendorsIDs),
      fetchStatus('Disabled Purposes', _cmpSdkPlugin.getDisabledPurposesIDs),
      fetchStatus('ATT Status', _cmpSdkPlugin.getATTAuthorizationStatus),
      fetchStatus(
          'Check if Consent is required (async)', checkIfConsentIsRequired),
    ];

    final List<String> statusReports = await Future.wait(statusFutures);
    final String statusString = statusReports.join('\n');

    _consentStatus = statusString;
    notifyListeners();
  }

  Future<void> importCmpString() async {
    if (_cmpString.isEmpty) {
      Fluttertoast.showToast(msg: 'CMP String is empty');
      return;
    }
    final success = await _cmpSdkPlugin.importCMPInfo(_cmpString);
    Fluttertoast.showToast(
        msg: success ? 'Import successful' : 'Import failed');
    if (success) {
      _cmpString = '';
    }
    notifyListeners();
  }

  Future<void> checkVendorConsent() async {
    if (_idString.isEmpty) {
      Fluttertoast.showToast(msg: 'Vendor ID is empty');
      return;
    }
    final hasConsent = await _cmpSdkPlugin.hasVendorConsent(_idString);
    Fluttertoast.showToast(
        msg: hasConsent
            ? 'Consent for vendor exists $_idString'
            : 'No consent for vendor: $_idString');
  }

  Future<void> checkPurposeConsent() async {
    if (_idString.isEmpty) {
      Fluttertoast.showToast(msg: 'Purpose ID is empty');
      return;
    }
    final hasConsent = await _cmpSdkPlugin.hasPurposeConsent(_idString);
    Fluttertoast.showToast(
        msg: hasConsent
            ? 'Consent for purpose exists $_idString'
            : 'No consent for purpose: $_idString');
  }

  Future<void> requestATTPermission() async {
    await _cmpSdkPlugin.requestATTPermission();
  }

  Future<void> getATTAuthorizationStatus() async {
    final lastRequest = await _cmpSdkPlugin.getATTAuthorizationStatus();
    Fluttertoast.showToast(msg: 'Authorization Status: ${lastRequest.name}');
  }

  void openConsentLayer() async {
    await _cmpSdkPlugin.openConsentLayer();
    notifyListeners();
  }
}
