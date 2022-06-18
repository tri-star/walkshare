import 'package:flutter/material.dart';
import 'package:strollog/layouts/before_signin_layout.dart';
import 'package:strollog/pages/app_page.dart';

class HomePage extends AppPage {
  @override
  Widget buildPage(BuildContext context) {
    return BeforeSigninLayout(Row(children: const []));
  }
}
