import 'package:flutter/material.dart';

typedef PageBuilder = Page Function();

/// ルート定義の1エントリ分を表すオブジェクト。
/// URIのシグネチャと、対応するページを構築するクロージャを持っている。
class RouteEntry {
  PageBuilder pageBuilder;
  RouteTransitionsBuilder? routeTransitionBuilder;

  RouteEntry({required this.pageBuilder, this.routeTransitionBuilder});
}

abstract class BaseRouteDefinition {
  late Map<String, RouteEntry> _routeEntries;

  void initialize();

  void setDefinition(Map<String, RouteEntry> definition) {
    _routeEntries = definition;
  }

  Map<String, RouteEntry> get entries => _routeEntries;
}
