import 'package:flutter/material.dart';

class WSButton extends StatelessWidget {
  final String title;
  final Icon? icon;
  final VoidCallback? onTap;

  WSButton({Key? key, required this.title, this.icon, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all(Theme.of(context).backgroundColor),
        elevation: MaterialStateProperty.all(2),
      ),
      child: Row(children: [
        icon ?? Container(),
        const SizedBox(
          width: 5,
        ),
        Text(title)
      ]),
      onPressed: () => onTap?.call(),
    );
  }
}
