import 'package:flutter/material.dart';

import 'constants/constants.dart';

enum CmpGravity { top, center, bottom }

class ConsentLayerUIConfig {
  final CmpPosition position;
  final CmpBackgroundStyle backgroundStyle;
  final double cornerRadius;
  final bool respectsSafeArea;
  final bool allowsOrientationChanges;
  final bool isCancelable;
  final Color? navigationBarColor;
  final Color? backgroundColor;
  final double? backgroundOpacity;
  final Size? customSize;
  final CmpGravity customGravity;
  final bool darkMode;

  ConsentLayerUIConfig({
    this.position = CmpPosition.fullScreen,
    this.backgroundStyle = CmpBackgroundStyle.dimmed,
    this.cornerRadius = 0.0,
    this.respectsSafeArea = true,
    this.allowsOrientationChanges = true,
    this.isCancelable = true,
    this.navigationBarColor,
    this.backgroundColor,
    this.backgroundOpacity,
    this.customSize,
    this.customGravity = CmpGravity.center,
    this.darkMode = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'position': _positionToString(),
      'backgroundStyle': _backgroundStyleToString(),
      'cornerRadius': cornerRadius,
      'respectsSafeArea': respectsSafeArea,
      'allowsOrientationChanges': allowsOrientationChanges,
      'isCancelable': isCancelable,
      'navigationBarColor': navigationBarColor?.value,
      'backgroundColor': backgroundColor?.value,
      'backgroundOpacity': backgroundOpacity,
      'customPosition': customSize != null
          ? {
              'width': customSize!.width,
              'height': customSize!.height,
              'gravity': _gravityToString(),
            }
          : null,
      'darkMode': darkMode,
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

  String _gravityToString() {
    switch (customGravity) {
      case CmpGravity.top:
        return 'top';
      case CmpGravity.bottom:
        return 'bottom';
      case CmpGravity.center:
        return 'center';
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
