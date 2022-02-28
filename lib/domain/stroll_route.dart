import 'package:strollog/domain/position.dart';

class StrollRoute {
  String? _id;

  final String _name;

  final DateTime _createdAt;

  final List<Position> _routePoints;

  StrollRoute(String name,
      {String? id, List<Position>? routePoints, DateTime? createdAt})
      : _id = id,
        _name = name,
        _routePoints = routePoints ?? [],
        _createdAt = createdAt ?? DateTime.now();

  String get id => _id ?? '';
  String get name => _name;
  List<Position> get routePoints => _routePoints;

  void addRoutePoint(Position position) {
    _routePoints.add(position);
  }

  void setId(String id) {
    _id = id;
  }
}
