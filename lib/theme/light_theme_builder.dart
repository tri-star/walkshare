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
      inputDecorationTheme: base.inputDecorationTheme
          .copyWith(hintStyle: const TextStyle(color: Colors.black45)),
      textTheme: base.textTheme.copyWith(
        // フォーム見出し
        labelMedium: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
      selectedRowColor: Colors.blue.shade200,
      listTileTheme: base.listTileTheme.copyWith(
          selectedTileColor: Colors.lightBlue.shade50,
          selectedColor: Colors.lightBlue.shade800),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
