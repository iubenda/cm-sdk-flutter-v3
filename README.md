# cmp_sdk_v3

A Flutter plugin for integrating and managing consent management platform (CMP) functionalities within your Flutter application. The `cmp_sdk` provides a simple and efficient way to handle user consents for data collection and usage in compliance with privacy laws like GDPR.

## Features

- Initialize CMP with custom configurations.
- Open consent layer UI with configurable presentation styles.
- Check and manage user consents for vendors and purposes.
- Import/export CMP configuration strings.
- Full support for custom callbacks and consent status checks.

## Installation

To use the `cmp_sdk` plugin, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  cmp_sdk: ^x.x.x
```

Then, run the following command to install the plugin:

```bash
flutter pub get
```

## Quick Start

To create an instance of `CmpSdk` with a basic configuration:

```dart
import 'package:cmp_sdk_v3/cmp_sdk_v3.dart';
import 'package:cmp_sdk_v3/cmp_config.dart';

void main() {
  runApp(MyApp());

  // Initialize CMP SDK with basic configuration
  final cmpSdk = CmpSdk.createInstance(
    id: "your_cmp_id",
    domain: "your_cmp_domain",
    appName: "your_app_name",
    language: "your_preferred_language",
  );
}
```

## Example Usage

Below is an example of how you can use the `cmp_sdk` within your application to configure the consent layer and handle user consents:

```dart
import 'package:flutter/material.dart';
import 'package:cmp_sdk_v3/cmp_sdk_v3.dart';
import 'package:cmp_sdk_v3/cmp_config.dart';
import 'package:cmp_sdk_v3/cmp_ui_config.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CmpSdk cmpSdk;

  @override
  void initState() {
    super.initState();
    initCmpSdk();
  }

  Future<void> initCmpSdk() async {
    // Create CMP SDK instance with custom configuration
    final cmpConfig = CmpConfig(
      id: "your_cmp_id",
      domain: "your_cmp_domain",
      appName: "your_app_name",
      language: "your_preferred_language",
      screenConfig: ScreenConfig.halfScreenBottom, //setting the layer screen
      iosPresentationStyle: IosPresentationStyle.popover,
      androidPresentationStyle: AndroidPresentationStyle.dialog,
      isDebugMode: true,
    );
    cmpSdk = CmpSdk.createInstanceWithConfig(cmpConfig);

    // Initialize CMP SDK and perform necessary setup
    await cmpSdk.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('CMP SDK Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Open the consent layer for the user to give consent
              await cmpSdk.openConsentLayer();
            },
            child: Text('Open Consent Layer'),
          ),
        ),
      ),
    );
  }
}
```

This example demonstrates how to initialize the `CmpSdk` with a custom configuration, configure the consent layer's UI, and then open the consent layer for user interaction.

For more detailed documentation and advanced usage, please refer to the official documentation.

## Documentation

For more detailed information on how to integrate and use cmp_sdk in your Flutter projects, including advanced configurations, consent layer customization, and handling user consents, please refer to our official documentation:

[Flutter Integration Guide](https://help.consentmanager.net/books/cmp/page/flutter-integration)

This guide provides step-by-step instructions, best practices, and additional resources to help you effectively implement and manage the CMP functionalities within your app.

## Support

For support and further questions, please contact the plugin maintainers or open an issue on the plugin's GitHub repository.
