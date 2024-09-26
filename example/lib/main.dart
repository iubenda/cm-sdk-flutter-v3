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
  const MyApp({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CmpViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CMP SDK V3 App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConsentLayerUIConfigCard(
              onConfigChanged: (ConsentLayerUIConfig config) {
                setState(() {});
              },
              onSubmit: (ConsentLayerUIConfig config) {
                viewModel.setWebViewConfig(config);
              },
            ),
            const SizedBox(height: 24.0),
            const ConfigSection(),
            const SizedBox(height: 24.0),
            const ActionButtons(),
            const SizedBox(height: 24.0),
            const StatusSection(),
            const SizedBox(height: 24.0),
            const LogsSection(),
          ],
        ),
      ),
    );
  }
}
