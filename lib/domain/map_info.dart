import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/domain/position.dart';

/// 地図上のスポット
class Spot {
  String title;

  String comment;

  DateTime date;

  Position point;

  double score;

  List<Photo> photos;

  Spot(this.title, this.point,
      {this.comment = "",
      DateTime? newDate,
      this.score = 1.0,
      List<Photo>? photos})
      : date = newDate ?? DateTime.now(),
        photos = photos ?? [];

  Spot.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        comment = json['comment'],
        date = json['date'].toDate(),
        point = Position(json['point'].latitude, json['point'].longitude),
        score = json['score'] + .0,
        photos = json.containsKey('photos')
            ? (json['photos'] as List<dynamic>)
                .map((photo) => Photo.fromJson(photo))
                .toList()
            : [];

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'comment': comment,
      'date': date,
      'point': GeoPoint(point.latitude, point.longitude),
      'score': score,
      'photos': photos.map((photo) => photo.toJson()).toList()
    };
  }

  void addPhotos(List<Photo> newPhotos) {
    photos.addAll(newPhotos);
  }
}

/// 地図情報。お気に入りスポットなどの点をまとめたもの。
class MapInfo {
  String? _id;

  String _name;

  List<Spot> _spots = [];

  MapInfo(this._name, this._spots, {String? id}) : _id = id;

  MapInfo.fromJson(String? id, Map<String, Object?> json)
      : _id = id,
        _name = json['name'] as String,
        _spots = (json['points'] as List<dynamic>)
            .map((dynamic p) => Spot.fromJson(p as Map<String, dynamic>))
            .toList();

  String? get id => _id;
  String get name => _name;
  List<Spot> get spots => _spots;

  void addSpot(Spot point) {
    _spots.add(point);
  }

  Map<String, Object?> toJson() {
    return {
      'name': _name,
      'points': _spots.map((Spot p) => p.toJson()).toList(),
    };
  }
}
