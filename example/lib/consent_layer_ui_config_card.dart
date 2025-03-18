import 'package:cm_cmp_sdk_v3/consent_layer_ui_config.dart';
import 'package:cm_cmp_sdk_v3/constants/constants.dart';
import 'package:flutter/material.dart';

class ConsentLayerUIConfigCard extends StatefulWidget {
  final Function(ConsentLayerUIConfig) onConfigChanged;
  final Function(ConsentLayerUIConfig) onSubmit;

  const ConsentLayerUIConfigCard({
    super.key,
    required this.onConfigChanged,
    required this.onSubmit,
  });

  @override
  ConsentLayerUIConfigCardState createState() =>
      ConsentLayerUIConfigCardState();
}

class ConsentLayerUIConfigCardState extends State<ConsentLayerUIConfigCard> {
  // Default values
  CmpPosition _position = CmpPosition.fullScreen;
  CmpBackgroundStyle _backgroundStyle = CmpBackgroundStyle.dimmed;
  double _cornerRadius = 0.0;
  bool _respectsSafeArea = true;
  bool _allowsOrientationChanges = true;
  Color? _backgroundColor = Colors.black;
  double _backgroundOpacity = 0.5;
  ConsentLayerUIConfig? _currentConfig;

  void _updateConfig() {
    // Create the ConsentLayerUIConfig and pass it to the parent widget
    final config = ConsentLayerUIConfig(
      position: _position,
      backgroundStyle: _backgroundStyle,
      cornerRadius: _cornerRadius,
      respectsSafeArea: _respectsSafeArea,
      allowsOrientationChanges: _allowsOrientationChanges,
      backgroundColor: _backgroundStyle == CmpBackgroundStyle.color
          ? _backgroundColor
          : null,
      backgroundOpacity: _backgroundStyle == CmpBackgroundStyle.dimmed
          ? _backgroundOpacity
          : null,
    );

    setState(() {
      _currentConfig = config;
    });

    widget.onConfigChanged(config);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown for Position
            _buildDropdown<CmpPosition>(
              label: "Position",
              value: _position,
              items: CmpPosition.values,
              onChanged: (CmpPosition? newValue) {
                setState(() {
                  _position = newValue!;
                });
                _updateConfig();
              },
            ),
            // Dropdown for BackgroundStyle
            _buildDropdown<CmpBackgroundStyle>(
              label: "Background Style",
              value: _backgroundStyle,
              items: CmpBackgroundStyle.values,
              onChanged: (CmpBackgroundStyle? newValue) {
                setState(() {
                  _backgroundStyle = newValue!;
                });
                _updateConfig();
              },
            ),
            // Slider for Corner Radius
            _buildSlider(
              label: "Corner Radius",
              value: _cornerRadius,
              min: 0,
              max: 50,
              onChanged: (double newValue) {
                setState(() {
                  _cornerRadius = newValue;
                });
                _updateConfig();
              },
            ),
            // Slider for Background Opacity (if dimmed style)
            if (_backgroundStyle == CmpBackgroundStyle.dimmed)
              _buildSlider(
                label: "Background Opacity",
                value: _backgroundOpacity,
                min: 0,
                max: 1,
                onChanged: (double newValue) {
                  setState(() {
                    _backgroundOpacity = newValue;
                  });
                  _updateConfig();
                },
              ),
            // Color picker for Background Color (if color style)
            if (_backgroundStyle == CmpBackgroundStyle.color)
              _buildColorPicker(
                label: "Background Color",
                currentColor: _backgroundColor!,
                onColorChanged: (Color newColor) {
                  setState(() {
                    _backgroundColor = newColor;
                  });
                  _updateConfig();
                },
              ),
            // Switch for Respects Safe Area
            _buildSwitch(
              label: "Respects Safe Area",
              value: _respectsSafeArea,
              onChanged: (bool newValue) {
                setState(() {
                  _respectsSafeArea = newValue;
                });
                _updateConfig();
              },
            ),
            // Switch for Allows Orientation Changes
            _buildSwitch(
              label: "Allows Orientation Changes",
              value: _allowsOrientationChanges,
              onChanged: (bool newValue) {
                setState(() {
                  _allowsOrientationChanges = newValue;
                });
                _updateConfig();
              },
            ),
            const SizedBox(height: 16.0),
            // Submit button
            ElevatedButton(
              onPressed: _currentConfig != null
                  ? () {
                widget.onSubmit(_currentConfig!); // Submit the config
              }
                  : null, // Disable button if no config
              child: const Text('Submit Configuration'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build a dropdown
  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Row(
      children: [
        Expanded(flex: 3, child: Text(label)),
        Expanded(
          flex: 7,
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            onChanged: onChanged,
            items: items
                .map((T item) => DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString().split('.').last),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }

  // Helper to build a slider
  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.toStringAsFixed(2)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Helper to build a switch
  Widget _buildSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }

  // Helper to build a color picker (simulated with a dropdown for simplicity)
  Widget _buildColorPicker({
    required String label,
    required Color currentColor,
    required ValueChanged<Color> onColorChanged,
  }) {
    return Row(
      children: [
        Expanded(flex: 3, child: Text(label)),
        Expanded(
          flex: 7,
          child: GestureDetector(
            onTap: () {
              // Show a dialog to pick a color (for simplicity, we'll cycle through a few colors)
              final colors = [
                Colors.red.shade100,
                Colors.green.shade100,
                Colors.blue.shade100,
                Colors.yellow.shade100,
              ];
              final nextColor =
              colors[(colors.indexOf(currentColor) + 1) % colors.length];
              onColorChanged(nextColor);
            },
            child: Container(
              width: 40,
              height: 40,
              color: currentColor,
            ),
          ),
        ),
      ],
    );
  }
}