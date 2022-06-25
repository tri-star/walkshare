import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/domain/user.dart';
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
        .get(const GetOptions(source: Source.server));

    if (snapshot.size == 0 || !snapshot.docs.first.exists) {
      return null;
    }

    var map = snapshot.docs.first.data();

    var spots = await FirebaseFirestore.instance
        .collection('maps')
        .doc(map.id)
        .collection('spots')
        .get(const GetOptions(source: Source.server));
    spots.docs.forEach((doc) async {
      var spot = await _makeSpot(doc);
      map.addSpot(spot);
    });

    return map;
  }

  Future<Spot> fetchSpot(MapInfo map, String spotId) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('maps')
        .doc(map.id)
        .collection('spots')
        .doc(spotId)
        .get();

    return _makeSpot(snapshot);
  }

  Future<void> addSpot(MapInfo map, String uid, Spot spot) async {
    map.spots[spot.id] = spot;
    var id = spot.id;
    await FirebaseFirestore.instance
        .collection('maps')
        .doc(map.id)
        .collection('spots')
        .doc(id)
        .set(_makeSpotJson(spot, uid));
  }

  Future<void> updatePoint(MapInfo map, String spotId, Spot spot) async {
    map.spots[spotId] = spot;
    await FirebaseFirestore.instance
        .collection('maps')
        .doc(map.id)
        .collection('spots')
        .doc(spotId)
        .set(_makeSpotJson(spot, spot.userNameInfo?.id));
  }

  Future<List<Photo>> uploadPhotos(
      MapInfo map, String uid, List<XFile> files) async {
    // CloudStorageにファイルをアップロードする
    // Photo形式に変換して返す
    List<Photo> photos = [];
    for (var file in files) {
      try {
        var photo = Photo.fromPath(file.path, uid);
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

  Map<String, dynamic> _makeSpotJson(Spot spot, String? uid) {
    return {
      'title': spot.title,
      'comment': spot.comment,
      'date': spot.date,
      'uid': uid != null
          ? FirebaseFirestore.instance.collection('users').doc(uid)
          : null,
      'point': GeoPoint(spot.point.latitude, spot.point.longitude),
      'score': spot.score,
      'photos': spot.photos.map((photo) => photo.toJson()).toList()
    };
  }

  Future<Spot> _makeSpot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    var data = snapshot.data()!;
    var userNameInfo = null;
    if (data['uid'] != null) {
      var userInfoData = (await data['uid'].get()).data();
      userNameInfo = UserNameInfo(data['uid'].id!, userInfoData['nickname']!);
    }
    var spot = Spot(data['title'],
        Position(data['point'].latitude, data['point'].longitude),
        id: snapshot.id,
        comment: data['comment'],
        newDate: data['date'].toDate(),
        score: data['score'] + .0,
        userNameInfo: userNameInfo,
        photos: (data['photos'] as List<dynamic>)
            .map((photo) => Photo.fromJson(photo))
            .toList());
    return spot;
  }
}
