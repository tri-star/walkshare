import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/domain/user.dart';

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

  Future<MapInfo?> fetchMapMetaById(String mapId) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('maps')
        .doc(mapId)
        .withConverter<MapInfo>(
            fromFirestore: (snapshot, _) =>
                MapInfo.fromJson(snapshot.id, snapshot.data()!),
            toFirestore: (MapInfo mapInfo, _) => mapInfo.toJson())
        .get(const GetOptions(source: Source.server));

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }

  Future<Map<String, MapInfo>> fetchMapMetaList() async {
    var collectionRef = await FirebaseFirestore.instance
        .collection('maps')
        .withConverter<MapInfo>(
            fromFirestore: (snapshot, _) =>
                MapInfo.fromJson(snapshot.id, snapshot.data()!),
            toFirestore: (MapInfo mapInfo, _) => mapInfo.toJson())
        .get(const GetOptions(source: Source.server));

    final Map<String, MapInfo> list = {};

    collectionRef.docs.forEach((snapshot) {
      final mapInfo = snapshot.data();
      list[mapInfo.id!] = mapInfo;
    });
    return list;
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
        .set(_makeSpotJson(map, spot, uid));
  }

  Future<void> updatePoint(MapInfo map, String spotId, Spot spot) async {
    map.spots[spotId] = spot;
    await FirebaseFirestore.instance
        .collection('maps')
        .doc(map.id)
        .collection('spots')
        .doc(spotId)
        .set(_makeSpotJson(map, spot, spot.userNameInfo?.id));
  }

  Map<String, dynamic> _makeSpotJson(MapInfo map, Spot spot, String? uid) {
    return {
      'title': spot.title,
      'comment': spot.comment,
      'date': spot.date,
      'uid': uid != null
          ? FirebaseFirestore.instance.collection('users').doc(uid)
          : null,
      'point': GeoPoint(spot.point.latitude, spot.point.longitude),
      'score': spot.score,
      'photos': spot.photos
          .map((photo) => FirebaseFirestore.instance
              .collection('maps')
              .doc(map.id)
              .collection('photos')
              .doc(photo.key))
          .toList()
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

    List<Photo> photos = [];
    await Future.forEach(data['photos'], (dynamic doc) async {
      var photoSnapShot = await doc.get();
      photos.add(Photo.fromJson(photoSnapShot.data()));
    });

    var spot = Spot(data['title'],
        Position(data['point'].latitude, data['point'].longitude),
        id: snapshot.id,
        comment: data['comment'],
        newDate: data['date'].toDate(),
        score: data['score'] + .0,
        userNameInfo: userNameInfo,
        photos: photos);
    return spot;
  }
}
