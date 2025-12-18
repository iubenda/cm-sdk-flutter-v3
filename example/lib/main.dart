// main.dart
import 'dart:developer' as developer;

import 'package:cm_cmp_sdk_v3/cm_cmp_sdk_v3.dart';
import 'package:cm_cmp_sdk_v3/cm_cmp_sdk_v3_platform_interface.dart';
import 'package:cm_cmp_sdk_v3/consent_layer_ui_config.dart';
import 'package:cm_cmp_sdk_v3/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CMP SDK Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CMPManager _cmpManager = CMPManager.instance;
  String _lastAction = '';

  // Pick ONE config below before running tests:
  ConsentLayerUIConfig get _selectedConfig {
    // final config = _fullScreenConfig;
    // final config = _halfScreenTopConfig;
    // final config = _halfScreenBottomConfig;
    final config = _customCenterConfig;
    return config;
  }

  ConsentLayerUIConfig get _fullScreenConfig => ConsentLayerUIConfig(
        position: CmpPosition.fullScreen,
        backgroundStyle: CmpBackgroundStyle.dimmed,
        backgroundOpacity: 0.5,
        cornerRadius: 0,
        darkMode: true,
        respectsSafeArea: true,
        allowsOrientationChanges: true,
        isCancelable: false,
      );

  ConsentLayerUIConfig get _halfScreenTopConfig => ConsentLayerUIConfig(
        position: CmpPosition.halfScreenTop,
        backgroundStyle: CmpBackgroundStyle.dimmed,
        backgroundOpacity: 0.9,
        cornerRadius: 20,
        darkMode: false,
        respectsSafeArea: true,
        allowsOrientationChanges: true,
        isCancelable: false,
      );

  ConsentLayerUIConfig get _halfScreenBottomConfig => ConsentLayerUIConfig(
        position: CmpPosition.halfScreenBottom,
        backgroundStyle: CmpBackgroundStyle.dimmed,
        backgroundOpacity: 0.6,
        cornerRadius: 12,
        darkMode: false,
        respectsSafeArea: true,
        allowsOrientationChanges: true,
        isCancelable: false,
      );

  ConsentLayerUIConfig get _customCenterConfig => ConsentLayerUIConfig(
        position: CmpPosition.custom,
        backgroundStyle: CmpBackgroundStyle.dimmed,
        backgroundOpacity: 0.6,
        cornerRadius: 16,
        customSize: const Size(320, 420),
        customGravity: CmpGravity.center,
        darkMode: false,
        respectsSafeArea: true,
        allowsOrientationChanges: true,
        isCancelable: false,
      );

  @override
  void initState() {
    super.initState();
    _initializeCMP();
  }

  Future<void> _initializeCMP() async {
    try {
      await CMPManager.instance.setWebViewConfig(_selectedConfig);
      await _cmpManager.setUrlConfig(
        id: "f5e3b73592c3c",
        domain: "a.delivery.consentmanager.net",
        appName: "CMDemoAppFlutter",
        language: "EN",
        // jsonConfig: '{"key":"value"}', // optional override
      );

      _cmpManager.addEventListeners(
        didReceiveConsent: (consent, jsonObject) {
          setState(() => _lastAction = 'Received consent: $consent');
        },
        didShowConsentLayer: () {
          setState(() => _lastAction = 'Consent layer shown');
        },
        didCloseConsentLayer: () {
          setState(() => _lastAction = 'Consent layer closed');
        },
        didReceiveError: (error) {
          setState(() => _lastAction = 'Error: $error');
        },
      );

      _cmpManager.setOnClickLinkCallback((url) {
        developer.log('Link clicked: $url', name: 'CMP_DEMO');
        try {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          setState(() => _lastAction = 'Opened in browser: $url');
          return true;
        } catch (e) {
          developer.log('Error opening URL: $url', name: 'CMP_DEMO', error: e);
          setState(() => _lastAction = 'Error opening URL: $e');
          return false;
        }
      });

      _checkIsConsentRequired();

      // await _cmpManager.checkAndOpen();
    } catch (e) {
      setState(() => _lastAction = 'Initialization error: $e');
    }
  }

  String _formatUserStatus(UserConsentStatus status) {
    return '''
User Choice: ${status.hasUserChoice}
TCF: ${status.tcf}
Additional Consent: ${status.addtlConsent}
Regulation: ${status.regulation}
Vendors: ${status.vendors.entries.map((e) => '${e.key}: ${e.value}').join(', ')}
Purposes: ${status.purposes.entries.map((e) => '${e.key}: ${e.value}').join(', ')}
''';
  }

  Future<void> _handleApiCall(Future<dynamic> Function() apiCall, String actionName) async {
    try {
      final result = await apiCall();
      setState(() {
        if (result is UserConsentStatus) {
          _lastAction = '$actionName:\n${_formatUserStatus(result)}';
        } else if (result is Map) {
          _lastAction = '$actionName: ${result.toString()}';
        } else {
          _lastAction = '$actionName: ${result.toString()}';
        }
      });
    } catch (e) {
      setState(() => _lastAction = '$actionName error: $e');
    }
  }

  Future<void> _checkIsConsentRequired() async {
    try {
      final isRequired = await _cmpManager.isConsentRequired();
      Fluttertoast.showToast(
        msg: 'Consent required: $isRequired',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() => _lastAction = 'Is Consent Required: $isRequired');
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error checking consent: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() => _lastAction = 'Is Consent Required error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CMP SDK Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Last Action:\n$_lastAction',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 20),
            _buildButton('Open Consent Layer',
                () => _handleApiCall(() => _cmpManager.forceOpen(), 'Force Open')),
            _buildButton('Check and Open',
                () => _handleApiCall(() => _cmpManager.checkAndOpen(), 'Check and Open')),
            _buildButton('Is Consent Required?', _checkIsConsentRequired),
            _buildButton('Jump to Settings',
                () => _handleApiCall(() => _cmpManager.forceOpen(jumpToSettings: true), 'Jump to Settings')),
            _buildButton('Accept All',
                () => _handleApiCall(() => _cmpManager.acceptAll(), 'Accept All')),
            _buildButton('Reject All',
                () => _handleApiCall(() => _cmpManager.rejectAll(), 'Reject All')),
            _buildButton('Export CMP Info',
                () => _handleApiCall(() => _cmpManager.exportCMPInfo(), 'Export CMP Info')),
            _buildButton('Import CMP Info (Test)',
                () => _handleApiCall(
                    () => _cmpManager.importCMPInfo(
                        'Q1FaRWVQQVFaRWVQQUFmYjRCRU5DQUZnQVBMQUFFTEFBQWlnRjV3QVFGNWdYbkFCQVhtQUFBI181MV81Ml81NF8jX3MxMDUyX3MxX3MyNl9zMjYxMl9zOTA1X3MxNDQ4X2M3MzczN19VXyMxLS0tIw'),
                    'Import CMP Info')),
            _buildButton('Get User Status',
                () => _handleApiCall(() => _cmpManager.getUserStatus(), 'User Status')),
            _buildButton('Reset Data',
                () => _handleApiCall(() => _cmpManager.resetConsentManagementData(), 'Reset Data')),
            _buildButton('Get Google Consent Mode',
                () => _handleApiCall(() => _cmpManager.getGoogleConsentModeStatus(), 'Google Consent Mode')),
            _buildButton('Check Vendor: s2789',
                () => _handleApiCall(() => _cmpManager.getStatusForVendor('s2789'), 'Vendor s2789')),
            _buildButton('Check Purpose: c53',
                () => _handleApiCall(() => _cmpManager.getStatusForPurpose('c53'), 'Purpose c53')),
            _buildButton('Accept Vendors s2790,s2791',
                () => _handleApiCall(() => _cmpManager.acceptVendors(['s2790', 's2791']), 'Accept Vendors')),
            _buildButton('Reject Vendors s2790,s2791',
                () => _handleApiCall(() => _cmpManager.rejectVendors(['s2790', 's2791']), 'Reject Vendors')),
            _buildButton('Accept Purposes c52,c53',
                () => _handleApiCall(() => _cmpManager.acceptPurposes(['c52', 'c53']), 'Accept Purposes')),
            _buildButton('Reject Purposes c52,c53',
                () => _handleApiCall(() => _cmpManager.rejectPurposes(['c52', 'c53']), 'Reject Purposes')),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
