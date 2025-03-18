import 'package:flutter/foundation.dart';
import 'package:cm_cmp_sdk_v3/cm_cmp_sdk_v3.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CmpViewModel extends ChangeNotifier {
  static final CmpViewModel _instance = CmpViewModel._internal();
  static CmpViewModel get instance => _instance;

  late CMPmanager _cmpSdkPlugin;
  String _callbackLogs = '';

  CmpViewModel._internal();

  Future<void> initCmp() async {
    try {
      _cmpSdkPlugin = CMPmanager.instance;

      await CMPmanager.instance.setUrlConfig(
        appName: "CMDemoAppFlutter",
        id: "26cba6cf81e76",
        language: "EN",
        domain: "delivery.consentmanager.net",
      );

      _addEventListeners();
      await _cmpSdkPlugin.checkAndOpen();

    } catch (e) {
      _logCallback('Initialization error: $e');
      rethrow;
    }
  }

  void _addEventListeners() {
    _cmpSdkPlugin.addEventListeners(
      didShowConsentLayer: () => _logCallback('Consent layer opened'),
      didCloseConsentLayer: () => _logCallback('Consent layer closed'),
      didReceiveError: (error) => _logCallback('Error: $error'),
      didReceiveConsent: (consent, jsonObject) =>
          _logCallback('Consent: $consent\nData: $jsonObject'),
      didChangeATTStatus: (oldStatus, newStatus, last) =>
          _logCallback('ATT Status changed: $oldStatus -> $newStatus'),
    );
  }

  void _logCallback(String message) {
    _callbackLogs = "$message\n$_callbackLogs";
    notifyListeners();
  }

  Future<void> getUserStatus() async {
    try {
      final status = await _cmpSdkPlugin.getUserStatus();
      final message = '''
User Choice: ${status.hasUserChoice}
TCF: ${status.tcf}
Additional Consent: ${status.addtlConsent}
Regulation: ${status.regulation}

Vendors Status:
${status.vendors.entries.map((e) => '${e.key}: ${e.value}').join('\n')}

Purposes Status:
${status.purposes.entries.map((e) => '${e.key}: ${e.value}').join('\n')}
''';
      _logCallback(message);
      Fluttertoast.showToast(msg: 'Check logs for User Status details');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error getting user status: $e');
    }
  }

  Future<void> exportCMPInfo() async {
    final cmpInfo = await _cmpSdkPlugin.exportCMPInfo();
    _logCallback('CMP String: $cmpInfo');
    Fluttertoast.showToast(msg: 'CMP String exported');
  }

  Future<void> getPurposeStatus() async {
    try {
      final status = await _cmpSdkPlugin.getStatusForPurpose('c53');
      Fluttertoast.showToast(msg: 'Purpose c53 status: $status');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error getting purpose status: $e');
    }
  }

  Future<void> enablePurposes() async {
    try {
      await _cmpSdkPlugin.acceptPurposes(['c52', 'c53']);
      Fluttertoast.showToast(msg: 'Purposes enabled');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error enabling purposes: $e');
    }
  }

  Future<void> disablePurposes() async {
    try {
      await _cmpSdkPlugin.rejectPurposes(['c52', 'c53']);
      Fluttertoast.showToast(msg: 'Purposes disabled');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error disabling purposes: $e');
    }
  }

  Future<void> getVendorStatus() async {
    try {
      final status = await _cmpSdkPlugin.getStatusForVendor('s2789');
      Fluttertoast.showToast(msg: 'Vendor s2789 status: $status');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error getting vendor status: $e');
    }
  }

  Future<void> enableVendors() async {
    try {
      await _cmpSdkPlugin.acceptVendors(['s2790', 's2791']);
      Fluttertoast.showToast(msg: 'Vendors enabled');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error enabling vendors: $e');
    }
  }

  Future<void> disableVendors() async {
    try {
      await _cmpSdkPlugin.rejectVendors(['s2790', 's2791']);
      Fluttertoast.showToast(msg: 'Vendors disabled');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error disabling vendors: $e');
    }
  }

  Future<void> acceptAll() async {
    try {
      await _cmpSdkPlugin.acceptAll();
      Fluttertoast.showToast(msg: 'All consents accepted');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error accepting all: $e');
    }
  }

  Future<void> rejectAll() async {
    try {
      await _cmpSdkPlugin.rejectAll();
      Fluttertoast.showToast(msg: 'All consents rejected');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error rejecting all: $e');
    }
  }

  Future<void> checkAndOpen() async {
    try {
      await _cmpSdkPlugin.checkAndOpen();
      Fluttertoast.showToast(msg: 'Checking and opening consent layer');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error checking and opening: $e');
    }
  }

  Future<void> forceOpen() async {
    try {
      await _cmpSdkPlugin.forceOpen();
      Fluttertoast.showToast(msg: 'Opening consent layer');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error opening consent layer: $e');
    }
  }

  Future<void> getGoogleConsentStatus() async {
    try {
      final settings = await _cmpSdkPlugin.getGoogleConsentModeStatus();
      final message = settings.entries.map((e) => '${e.key}: ${e.value}').join('\n');
      _logCallback('Google Consent Mode Settings:\n$message');
      Fluttertoast.showToast(msg: 'Check logs for Google Consent Mode settings');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error getting Google Consent Mode status: $e');
    }
  }

  Future<void> jumpToSettings() async {
    try {
      await _cmpSdkPlugin.forceOpen(jumpToSettings: true);
      Fluttertoast.showToast(msg: 'Opening CMP Settings');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error opening settings: $e');
    }
  }

  Future<void> importCMPString() async {
    try {
      const cmpString = "Q1FMVW10Z1FMVW10Z0FmUTVDSVRCWUZnQUFBQUFBQUFBQWlnS3dOWF9HX19iWGx2LVg3MzZmdGtlWTFmOTloNzdzUXhCaGZKcy00RnpMdldfSndYMzJFek5FMzZ0cVlLbVJJQXUzVEJJUU50R0pqVVJWQ2hhb2dWcnpEc2FFeVVvVHRLSi1Ca2lITVJZMmRZQ0Z4dm00dGplUUNaNXZyXzkxZDUyUl90N2RyLTNkenl5NWhudjNhOV8tUzFXSmlkSzUtdEhfdjliUk9iLV9JLTlfeC1fNHY0X05fcEUyX2VUMXRfdFd2dDczOS04dHZfOV9fOTlfX19fZl9fX19fXzNfLV9mX19mX19fOEZYd0NURFFxSUF5d0pDUWcwRENDQkFDb0t3Z0lvRUFRQUFKQTBRRUFKZ3dLZGdZQUxyQ1JBQ0FGQUFNRUFJQUFRWkFBZ0FBQWdBUWlBQ0FBb0VBQUVBZ1VBQVlBRUF3RUFCQXdBQWdBc0JBSUFBUUhRTVV3SUlCQXNBRWpNaW9Vd0lRZ0VnZ0piS2hCSUFnUVZ3aENMUEFJZ0VSTUZBQUFBQUFVZ0FDQXNGZ2NTU0FsUWtFQVhFRzBBQUJBQWdFRUFCUWdrNU1BQVFCbXkxQjRNRzBaV21BWVBtQ1JEVEFNZ0NJSXlFZzBBQUEjXzUxXzUyXzUzXzU0XzU1XzU2XyNfczI4MTVfYzY0MDQzX3MyODE0X3MyNzYyX3MyODg1X3MyODE5X3MyODQ2X3MzMDM1X3MyNDM0X1VfIzEtLS0j";
      final success = await _cmpSdkPlugin.importCMPInfo(cmpString);
      if (success) {
        Fluttertoast.showToast(msg: 'New consent string imported successfully');
      } else {
        Fluttertoast.showToast(msg: 'Import failed');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error importing CMP string: $e');
    }
  }

  Future<void> resetConsent() async {
    try {
      await _cmpSdkPlugin.resetConsentManagementData();
      Fluttertoast.showToast(msg: 'All consents reset');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error resetting consents: $e');
    }
  }
}