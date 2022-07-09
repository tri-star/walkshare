import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/pages/app_page.dart';
import 'package:strollog/pages/map/map_page.dart';
import 'package:strollog/services/auth_service.dart';

class WalkShareApp extends AppPage {
  @override
  Widget buildPage(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    if (!authService.isSignedIn()) {
      return const CircularProgressIndicator();
    }

    return MapPage();
  }
}
