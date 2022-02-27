import 'package:strollog/domain/position.dart';

class StrollRoute {
  List<Position> _routePoints;

  StrollRoute({List<Position>? routePoints}) : _routePoints = routePoints ?? [];

  List<Position> get routePoints => _routePoints;

  void addRoutePoint(Position position) {
    _routePoints.add(position);
  }
}
