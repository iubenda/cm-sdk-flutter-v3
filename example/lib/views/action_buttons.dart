import 'package:cmp_sdk_example/viewmodels/cmp_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CmpViewModel>(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildIconActionButton(
            label: 'User Status',
            icon: Icons.person_outline,
            onPressed: viewModel.getUserStatus,
          ),
          _buildIconActionButton(
            label: 'Status for Purpose c53',
            icon: Icons.assignment_outlined,
            onPressed: () => viewModel.getStatusForPurpose('c53'),
          ),
          _buildIconActionButton(
            label: 'Status for Vendor s2789',
            icon: Icons.business_outlined,
            onPressed: () => viewModel.getStatusForVendor('s2789'),
          ),
          _buildIconActionButton(
            label: 'Google Consent',
            icon: Icons.settings_applications_outlined,
            onPressed: viewModel.getGoogleConsentModeStatus,
          ),
          _buildIconActionButton(
            label: 'Open',
            icon: Icons.open_in_browser,
            onPressed: viewModel.forceOpen,
          ),
          _buildIconActionButton(
            label: 'Accept',
            icon: Icons.thumb_up,
            onPressed: viewModel.acceptAll,
          ),
          _buildIconActionButton(
            label: 'Reject',
            icon: Icons.thumb_down,
            onPressed: viewModel.rejectAll,
          ),
          _buildIconActionButton(
            label: 'Status',
            icon: Icons.info,
            onPressed: viewModel.getStatus,
          ),
          _buildIconActionButton(
            label: 'Import CMP',
            icon: Icons.upload_file,
            onPressed: viewModel.importCmpString,
          ),
          _buildIconActionButton(
            label: 'Disable Vendors',
            icon: Icons.block,
            onPressed: viewModel.disableVendors,
          ),
          _buildIconActionButton(
            label: 'Enable Vendors',
            icon: Icons.check,
            onPressed: viewModel.enableVendors,
          ),
          _buildIconActionButton(
            label: 'Disable Purposes',
            icon: Icons.remove_circle_outline,
            onPressed: viewModel.disablePurposes,
          ),
          _buildIconActionButton(
            label: 'Enable Purposes',
            icon: Icons.add_circle_outline,
            onPressed: viewModel.enablePurposes,
          ),
          _buildIconActionButton(
            label: 'Request ATT',
            icon: Icons.privacy_tip,
            onPressed: viewModel.requestATTPermission,
          ),
          _buildIconActionButton(
            label: 'ATT Status',
            icon: Icons.check_circle_outline,
            onPressed: viewModel.getATTAuthorizationStatus,
          ),
          _buildIconActionButton(
            label: 'Reset',
            icon: Icons.restart_alt,
            onPressed: viewModel.resetConsent,
          ),
        ],
      ),
    );
  }

  Widget _buildIconActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: onPressed,
            tooltip: label,
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
