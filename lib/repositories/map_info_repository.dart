import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/photo.dart';

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
    return snapshot.docs.first.data();
  }

  Future<void> addPoint(MapInfo map, MapPoint point) async {
    map.points.add(point);
    await FirebaseFirestore.instance.collection('maps').doc(map.id).update({
      'points': FieldValue.arrayUnion([point.toJson()])
    });
  }

  Future<void> updatePoint(MapInfo map, int index, MapPoint point) async {
    map.points[index] = point;
    await FirebaseFirestore.instance
        .collection('maps')
        .doc(map.id)
        .update({'points': map.points.map((p) => p.toJson()).toList()});
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
