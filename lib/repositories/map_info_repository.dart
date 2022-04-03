import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/domain/position.dart';
import 'package:ulid/ulid.dart';

/// マップ情報は頻繁に更新するわけではなく、ユーザー間で共有する場合も適宜リロードしてもらえば良いので
/// Streamの購読は不要と考える
class MapInfoRepository {
  Future<MapInfo?> fetchMapByName(String name) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('maps')
        .withConverter<MapInfo>(
            fromFirestore: (snapshot, _) =>
                MapInfo.fromJson(snapshot.id, snapshot.data()!),
            toFirestore: (MapInfo mapInfo, _) => mapInfo.toJson())
        .where('name', isEqualTo: name)
        .get();

    if (!snapshot.docs.first.exists) {
      return null;
    }

    var map = snapshot.docs.first.data();

    var spots = await FirebaseFirestore.instance
        .collection('maps')
        .doc(map.id)
        .collection('spots')
        .get();
    spots.docs.forEach((doc) {
      var data = doc.data();
      var spot = Spot(data['title'],
          Position(data['point'].latitude, data['point'].longitude),
          id: doc.id,
          comment: data['comment'],
          newDate: data['date'].toDate(),
          score: data['score'] + .0,
          photos: (data['photos'] as List<dynamic>)
              .map((photo) => Photo.fromJson(photo))
              .toList());
      map.addSpot(spot);
    });

    return map;
  }

  Future<void> addSpot(MapInfo map, Spot spot) async {
    map.spots[spot.id] = spot;
    var id = spot.id;
    await FirebaseFirestore.instance
        .collection('maps')
        .doc(map.id)
        .collection('spots')
        .doc(id)
        .set(spot.toJson());
  }

  Future<void> updatePoint(MapInfo map, String spotId, Spot spot) async {
    map.spots[spotId] = spot;
    await FirebaseFirestore.instance
        .collection('maps')
        .doc(map.id)
        .collection('spots')
        .doc(spotId)
        .set(spot.toJson());
  }

  Future<List<Photo>> uploadPhotos(MapInfo map, List<XFile> files) async {
    // CloudStorageにファイルをアップロードする
    // Photo形式に変換して返す
    List<Photo> photos = [];
    for (var file in files) {
      try {
        var photo = Photo.fromPath(file.path);
        var path = "maps/${map.name}/${photo.getFileName()}";
        await FirebaseStorage.instance.ref(path).putFile(File(file.path));

        photos.add(photo);
      } on FirebaseException catch (e) {
        FirebaseCrashlytics.instance.recordError(e, e.stackTrace);
      }
    }
    return photos;
  }

  String _createPhotoPath(String mapName, Photo photo) {
    var fileName = photo.getFileName();
    return 'maps/$mapName/$fileName';
  }
}
