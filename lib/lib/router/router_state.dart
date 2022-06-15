import 'package:flutter/material.dart';
import '../router/app_location.dart';

class RouterState with ChangeNotifier {
  List<AppLocation> _history = [];

  RouterState(AppLocation currentRoute) {
    _history.add(currentRoute);
  }

  AppLocation get currentRoute => _history.last;

  void setRoute(AppLocation route) {
    _history = [route];
    notifyListeners();
  }

  bool canPop() {
    return _history.length > 1;
  }

  void pushRoute(AppLocation route) {
    _history.add(route);
    notifyListeners();
  }

  void replaceRoute(AppLocation route) {
    _history.removeLast();
    _history.add(route);
    notifyListeners();
  }

  void popRoute() {
    _history.removeLast();
    notifyListeners();
  }
}
