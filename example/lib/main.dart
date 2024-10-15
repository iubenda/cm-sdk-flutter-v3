import 'package:cmp_sdk_example/widgets/consent_layer_ui_config_card.dart';
import 'package:cmp_sdk_v3/consent_layer_ui_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/cmp_view_model.dart';
import 'views/config_section.dart';
import 'views/action_buttons.dart';
import 'views/status_section.dart';
import 'views/logs_section.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CmpViewModel()),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
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
    // Calling initCmp() after the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CmpViewModel>(context, listen: false).initCmp();
    });
  }

  // Function to show the UI Config Card in a modal
  void _showConfigModal(BuildContext context) {
    final viewModel = Provider.of<CmpViewModel>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FractionallySizedBox(
            heightFactor: 0.7, // Adjust the modal height if necessary
            child: ConsentLayerUIConfigCard(
              onConfigChanged: (ConsentLayerUIConfig config) {
                setState(() {});
              },
              onSubmit: (ConsentLayerUIConfig config) {
                viewModel.setWebViewConfig(config);
                Navigator.of(context).pop(); // Close the modal on submit
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<CmpViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CMP SDK V3 App'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConfigSection(),
            SizedBox(height: 24.0),
            ActionButtons(),
            SizedBox(height: 24.0),
            StatusSection(),
            SizedBox(height: 24.0),
            LogsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showConfigModal(context), // Show the settings modal
        child: const Icon(Icons.settings), // Settings icon for the button
      ),
    );
  }
}
