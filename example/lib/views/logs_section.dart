import 'package:cmp_sdk_example/viewmodels/cmp_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogsSection extends StatelessWidget {
  const LogsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CmpViewModel>(context);

    return Card(
      child: ListTile(
        title: const Text('Callback Logs'),
        subtitle: Text(
          viewModel.callbackLogs.isEmpty ? 'No logs' : viewModel.callbackLogs,
        ),
      ),
    );
  }
}
