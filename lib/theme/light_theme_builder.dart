import 'package:flutter/material.dart';

class LightThemeBuilder {
  ThemeData build() {
    final base = ThemeData.light();
    return base.copyWith(
      dividerTheme: base.dividerTheme.copyWith(
        color: Colors.black,
        space: 10,
        thickness: 10,
      ),
      textTheme: base.textTheme.copyWith(
          // フォーム見出し
          labelMedium: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
