import 'package:flutter/material.dart';

import 'constants/constants.dart';

class ConsentLayerUIConfig {
  final CmpPosition position;
  final CmpBackgroundStyle backgroundStyle;
  final double cornerRadius;
  final bool respectsSafeArea;
  final bool allowsOrientationChanges;
  final Color? backgroundColor;
  final double? backgroundOpacity;
  final Rect? customPosition;

  ConsentLayerUIConfig({
    this.position = CmpPosition.fullScreen,
    this.backgroundStyle = CmpBackgroundStyle.dimmed,
    this.cornerRadius = 0.0,
    this.respectsSafeArea = true,
    this.allowsOrientationChanges = true,
    this.backgroundColor,
    this.backgroundOpacity,
    this.customPosition,
  });

  // Convert to a map to send to native iOS
  Map<String, dynamic> toMap() {
    return {
      'position': _positionToString(),
      'backgroundStyle': _backgroundStyleToString(),
      'cornerRadius': cornerRadius,
      'respectsSafeArea': respectsSafeArea,
      'allowsOrientationChanges': allowsOrientationChanges,
      'backgroundColor': backgroundColor?.value,
      'backgroundOpacity': backgroundOpacity,
      'customPosition': customPosition != null
          ? {
              'left': customPosition!.left,
              'top': customPosition!.top,
              'right': customPosition!.right,
              'bottom': customPosition!.bottom,
            }
          : null,
    };
  }

  String _positionToString() {
    switch (position) {
      case CmpPosition.fullScreen:
        return 'fullScreen';
      case CmpPosition.halfScreenTop:
        return 'halfScreenTop';
      case CmpPosition.halfScreenBottom:
        return 'halfScreenBottom';
      case CmpPosition.custom:
        return 'custom';
    }
  }

  String _backgroundStyleToString() {
    switch (backgroundStyle) {
      case CmpBackgroundStyle.dimmed:
        return 'dimmed';
      case CmpBackgroundStyle.blur:
        return 'blur';
      case CmpBackgroundStyle.color:
        return 'color';
      case CmpBackgroundStyle.none:
        return 'none';
    }
  }
}
