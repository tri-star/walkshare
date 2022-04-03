import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/domain/position.dart';
import 'package:ulid/ulid.dart';

/// 地図上のスポット
class Spot {
  String id;

  String title;

  String comment;

  DateTime date;

  Position point;

  double score;

  List<Photo> photos;

  Spot(this.title, this.point,
      {String? id,
      this.comment = "",
      DateTime? newDate,
      this.score = 1.0,
      List<Photo>? photos})
      : id = id ?? Ulid().toString(),
        date = newDate ?? DateTime.now(),
        photos = photos ?? [];

  // Spot.fromJson(Map<String, dynamic> json)
  //     : title = json['title'],
  //       comment = json['comment'],
  //       date = json['date'].toDate(),
  //       point = Position(json['point'].latitude, json['point'].longitude),
  //       score = json['score'] + .0,
  //       photos = json.containsKey('photos')
  //           ? (json['photos'] as List<dynamic>)
  //               .map((photo) => Photo.fromJson(photo))
  //               .toList()
  //           : [];

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

  Map<String, Spot> _spots = {};

  MapInfo(this._name, this._spots, {String? id}) : _id = id;

  MapInfo.fromJson(String? id, Map<String, Object?> json)
      : _id = id,
        _name = json['name'] as String;

  String? get id => _id;
  String get name => _name;
  Map<String, Spot> get spots => _spots;

  void addSpot(Spot spot) {
    _spots[spot.id] = spot;
  }

  Map<String, Object?> toJson() {
    return {
      'name': _name,
    };
  }
}
