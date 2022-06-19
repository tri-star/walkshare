import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/lib/router/app_location.dart';
import 'package:strollog/lib/router/guard.dart';
import 'package:strollog/router/app_location.dart';
import 'package:strollog/services/auth_service.dart';

class AppGuard extends RouteGuard {
  @override
  AppLocation? invoke(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    if (!authService.isSignedIn()) {
      return AppLocationSignin();
    }
    return null;
  }
}
