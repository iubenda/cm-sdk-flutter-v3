import 'package:cmp_sdk_example/viewmodels/cmp_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusSection extends StatelessWidget {
  const StatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CmpViewModel>(context);

    return Card(
      child: ListTile(
        title: const Text('Consent Status'),
        subtitle: Text(
          viewModel.consentStatus.isEmpty
              ? 'No status available'
              : viewModel.consentStatus,
        ),
      ),
    );
  }
}
