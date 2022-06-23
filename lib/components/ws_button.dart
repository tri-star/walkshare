import 'package:flutter/material.dart';

class WSButton extends StatelessWidget {
  final String title;
  final Icon? icon;
  final VoidCallback? onTap;

  WSButton({Key? key, required this.title, this.icon, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return ElevatedButton.icon(
      style: theme.elevatedButtonTheme.style,
      icon: icon!,
      label: Row(children: [
        Text(
          title,
        )
      ]),
      onPressed: () => onTap?.call(),
    );
  }
}
