import 'package:flutter/material.dart';
import 'package:strollog/lib/router/guard.dart';

typedef PageBuilder = Page Function();
typedef RouteDefineFunction = void Function(
    void Function({required String path, required PageBuilder pageBuilder}));

/// ルート定義の1エントリ分を表すオブジェクト。
/// URIのシグネチャと、対応するページを構築するクロージャを持っている。
class RouteEntry {
  String path;
  RouteGuard? guard;
  PageBuilder pageBuilder;

  RouteEntry({required this.path, this.guard, required this.pageBuilder});
}

class BaseRouteDefinition {
  Map<String, RouteEntry> _routeEntries = {};

  BaseRouteDefinition();

  void setDefinition(Map<String, RouteEntry> definition) {
    _routeEntries = definition;
  }

  void add(String path, PageBuilder pageBuilder, {RouteGuard? guard}) {
    _routeEntries[path] =
        RouteEntry(path: path, guard: guard, pageBuilder: pageBuilder);
  }

  void guard(RouteGuard guard, RouteDefineFunction closure) {
    definer({required String path, required PageBuilder pageBuilder}) {
      add(path, pageBuilder, guard: guard);
    }

    closure.call(definer);
  }

  Map<String, RouteEntry> get entries => _routeEntries;
}
