import 'package:flutter/material.dart';

class BeforeSigninLayout extends StatelessWidget {
  final Widget _content;

  const BeforeSigninLayout(Widget child,
      {Widget? floatingActionButton, Key? key})
      : _content = child,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WalkShare'),
      ),
      body: SafeArea(child: _content),
    );
  }
}
