import 'package:cmp_sdk_example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cm_cmp_sdk_v3/cm_cmp_sdk_v3.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Instance of your CmpSdk plugin
  final CMPmanager cmpSdkPlugin = CMPmanager.instance;
  const String testId = "b43fcc03b1a67";
  const String testDomain = "delivery.consentmanager.net";
  const String testAppName = "TestApp";
  const String testLanguage = "en";
  const List<String> testVendorIds = ["s1", "2"]; // Example vendor IDs
  const List<String> testPurposeIds = ["1", "s2"]; // Example purpose IDs
  const Map<String, bool> expectedVendorResults = {
    "s1": true,
    "2": false,
  };
  const Map<String, bool> expectedPurposeResults = {
    "1": true,
    "s2": true,
  };

  group('CmpSdk Integration Tests', () {
    // Initialize the CMP SDK
    testWidgets('CMP SDK Initialization', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      CMPmanager.instance.setUrlConfig(
          id: testId,
          domain: testDomain,
          appName: testAppName,
          language: testLanguage);
    });

    String? exportedCmpString;
    testWidgets('Export CMP String', (WidgetTester tester) async {
      await cmpSdkPlugin.acceptAll();
      exportedCmpString = await cmpSdkPlugin.exportCMPInfo();
      expect(exportedCmpString?.isNotEmpty, true);
    });

    testWidgets('Import CMP String', (WidgetTester tester) async {
      final importSuccess =
          await cmpSdkPlugin.importCMPInfo(exportedCmpString!);
      expect(importSuccess, true);
    });

    for (var vendorId in testVendorIds) {
      testWidgets('Check Vendor Consent for $vendorId',
          (WidgetTester tester) async {
        final hasConsent = await cmpSdkPlugin.hasVendorConsent(
          vendorId,
        );
        expect(hasConsent, expectedVendorResults[vendorId]);
      });
    }

    for (var purposeId in testPurposeIds) {
      testWidgets('Check Purpose Consent for $purposeId',
          (WidgetTester tester) async {
        final hasConsent = await cmpSdkPlugin.hasPurposeConsent(purposeId);
        expect(hasConsent, expectedPurposeResults[purposeId]);
      });
    }
  });
}
