import 'package:strollog/lib/router/base_route_definitions.dart';
import 'package:strollog/pages/auth_page.dart';
import 'package:strollog/pages/map/spot_edit_page.dart';
import 'package:strollog/pages/map/spot_create_page.dart';
import 'package:strollog/pages/name_management/name_detail_page.dart';
import 'package:strollog/pages/name_management/name_edit_page.dart';
import 'package:strollog/pages/name_management/name_list_page.dart';
import 'package:strollog/pages/walkshare_app.dart';
import 'package:strollog/router/app_guard.dart';

class RouteDefinition extends BaseRouteDefinition {
  RouteDefinition() {
    add('/signin', () => AuthPage());

    guard(AppGuard(), (route) {
      route(path: '/', pageBuilder: () => WalkShareApp());
      route(path: '/map/:mapId/names', pageBuilder: () => NameListPage());
      route(
          path: '/map/:mapId/names/:nameId',
          pageBuilder: () => NameDetailPage());
      route(
          path: '/map/:mapId/names/:nameId/edit',
          pageBuilder: () => NameEditPage());
      route(
          path: '/map/:mapId/spot/create', pageBuilder: () => SpotCreatePage());
      route(
          path: '/map/:mapId/spot/edit/:spotId',
          pageBuilder: () => SpotEditPage());
    });
  }
}
