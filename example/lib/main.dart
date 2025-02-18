import 'package:cmp_sdk_example/cmp_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: CmpViewModel.instance,
      child: MaterialApp(
        title: 'CMP Demo App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CmpViewModel.instance.initCmp();
    });
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CM Flutter DemoApp'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildButton('Get User Status', Colors.blue,
                    () => CmpViewModel.instance.getUserStatus()),
            _buildButton('Get CMP String', Colors.teal,
                    () => CmpViewModel.instance.exportCMPInfo()),
            _buildButton('Status for Purpose c53', const Color(0xFF3CB371),
                    () => CmpViewModel.instance.getPurposeStatus()),
            _buildButton('Enable Purposes c52 and c53', const Color(0xFF3CB371),
                    () => CmpViewModel.instance.enablePurposes()),
            _buildButton('Disable Purposes c52 and c53', Colors.red,
                    () => CmpViewModel.instance.disablePurposes()),
            _buildButton('Status for Vendor ID s2789', Colors.cyan,
                    () => CmpViewModel.instance.getVendorStatus()),
            _buildButton('Enable Vendors s2790 and s2791', Colors.cyan,
                    () => CmpViewModel.instance.enableVendors()),
            _buildButton('Disable Vendors s2790 and s2791', Colors.red,
                    () => CmpViewModel.instance.disableVendors()),
            _buildButton('Reject All', Colors.red,
                    () => CmpViewModel.instance.rejectAll()),
            _buildButton('Accept All', Colors.green,
                    () => CmpViewModel.instance.acceptAll()),
            _buildButton('Check and Open Consent Layer', Colors.indigo,
                    () => CmpViewModel.instance.checkAndOpen()),
            _buildButton('Open Consent Layer', Colors.indigo,
                    () => CmpViewModel.instance.forceOpen()),
            _buildButton('Get Google Consent Mode', Colors.indigo,
                    () => CmpViewModel.instance.getGoogleConsentStatus()),
            _buildButton('Jump to CMP Settings', Colors.indigo,
                    () => CmpViewModel.instance.jumpToSettings()),
            _buildButton('Import CMP String', Colors.teal,
                    () => CmpViewModel.instance.importCMPString()),
            _buildButton('Reset all CMP Info', Colors.black,
                    () => CmpViewModel.instance.resetConsent()),
            _buildButton('Request ATT Authorization', Colors.purple,
                    () => CmpViewModel.instance.requestATTPermission()),
          ],
        ),
      ),
    );
  }
}