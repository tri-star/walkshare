import 'package:flutter/material.dart';

class WsFormLabel extends StatelessWidget {
  final String text;
  final double w;
  final bool required;

  const WsFormLabel(
      {Key? key, required this.text, this.w = 100, this.required = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var labelText = text;

    if (required) {
      labelText += ' (*)';
    }

    return Text(labelText, style: theme.textTheme.labelMedium);
  }
}
