import 'package:flutter/material.dart';

class LightThemeBuilder {
  ThemeData build() {
    final base = ThemeData.light();
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
          // フォーム見出し
          labelMedium: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
