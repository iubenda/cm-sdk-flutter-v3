import 'package:cmp_sdk_example/viewmodels/cmp_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfigSection extends StatelessWidget {
  const ConfigSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CmpViewModel>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue:
                  viewModel.cmpString, // Use the current value in the ViewModel
              decoration: const InputDecoration(
                labelText: 'Enter CMP import string',
              ),
              onChanged: (value) {
                viewModel.setCmpString(value); // Update ViewModel
              },
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              initialValue:
                  viewModel.idString, // Use the current value in the ViewModel
              decoration: const InputDecoration(
                labelText: 'Enter Purpose/Vendor ID',
              ),
              onChanged: (value) {
                viewModel.setIdString(value); // Update ViewModel
              },
            ),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }
}
