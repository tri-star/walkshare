import 'dart:convert';

import 'package:flutter/material.dart';

class WsFormValueLabel extends StatelessWidget {
  final String value;

  const WsFormValueLabel({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var labelText = value;

    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 1, color: theme.dividerColor))),
        padding: const EdgeInsets.only(top: 10),
        child: Row(children: [
          Text(
            labelText,
          ),
        ]));
  }
}
