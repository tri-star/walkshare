import 'package:strollog/lib/router/base_route_definitions.dart';
import 'package:strollog/pages/auth_page.dart';
import 'package:strollog/pages/walkshare_app.dart';
import 'package:strollog/router/app_guard.dart';

class RouteDefinition extends BaseRouteDefinition {
  RouteDefinition() {
    add('/signin', () => AuthPage());

    guard(AppGuard(), (route) {
      route(path: '/', pageBuilder: () => WalkShareApp());
    });
  }
}
