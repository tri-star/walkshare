import 'package:flutter/material.dart';
import 'package:strollog/lib/router/app_location.dart';

typedef GuardFunction = AppLocation? Function();

abstract class RouteGuard {
  AppLocation? invoke(BuildContext context);
}
