import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strollog/domain/position.dart';

class MapPoint {
  String comment;

  DateTime date;

  Position point;

  double score;

  MapPoint(this.point, {this.comment = "", DateTime? newDate, this.score = 1.0})
      : date = newDate ?? DateTime.now();

  MapPoint.fromJson(Map<String, dynamic> json)
      : comment = json['comment'],
        date = DateTime.parse(json['date']),
        point = Position(json['point']['latitude'], json['point']['longitude']),
        score = json['score'];

  Map<String, Object?> toJson() {
    return {
      'comment': comment,
      'date': date.toIso8601String(),
      'point': GeoPoint(point.latitude, point.longitude),
      'score': score,
    };
  }
}

class MapInfo {
  String? _id;

  String _name;

  List<MapPoint> _points = [];

  MapInfo(this._name, this._points, {String? id}) : _id = id;

  MapInfo.fromJson(String? id, Map<String, Object?> json)
      : _id = id,
        _name = json['name'] as String,
        _points = (json['points'] as List<dynamic>)
            .map((dynamic p) => MapPoint.fromJson(p as Map<String, dynamic>))
            .toList();

  String? get id => _id;
  String get name => _name;
  List<MapPoint> get points => _points;

  void addPoint(MapPoint point) {
    _points.add(point);
  }

  Map<String, Object?> toJson() {
    return {
      'name': _name,
      'points': _points.map((MapPoint p) => p.toJson()).toList(),
    };
  }
}
