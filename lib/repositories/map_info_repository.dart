import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strollog/domain/face_photo.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/domain/user.dart';

/// マップ情報は頻繁に更新するわけではなく、ユーザー間で共有する場合も適宜リロードしてもらえば良いので
/// Streamの購読は不要と考える
class MapInfoRepository {
  FirebaseFirestore _firestore;

  MapInfoRepository(this._firestore);

  Future<MapInfo?> fetchMapByName(String name) async {
    var snapshot = await _firestore
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

    var spots = await _firestore
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
    var snapshot = await _firestore
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
    var collectionRef = await _firestore
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

  Future<void> save(MapInfo mapInfo) async {
    await _firestore.collection('maps').doc(mapInfo.id!).set(mapInfo.toJson());
  }

  Future<Spot> fetchSpot(MapInfo map, String spotId) async {
    var snapshot = await _firestore
        .collection('maps')
        .doc(map.id)
        .collection('spots')
        .doc(spotId)
        .get();

    return _makeSpot(snapshot);
  }

  Stream<Map<String, Spot>> subscribeSpotStream(MapInfo map) {
    return _firestore
        .collection('maps')
        .doc(map.id)
        .collection('spots')
        .snapshots()
        .asyncMap((querySnapshot) async {
      var result = <String, Spot>{};
      await Future.forEach(querySnapshot.docs, (element) async {
        var documentSnapshot =
            element as DocumentSnapshot<Map<String, dynamic>>;
        result[documentSnapshot.id] =
            await _makeSpot(documentSnapshot, shallow: true);
      });

      return result;
    });
  }

  Future<void> addSpot(MapInfo map, String uid, Spot spot) async {
    map.spots[spot.id] = spot;
    var id = spot.id;
    await _firestore
        .collection('maps')
        .doc(map.id)
        .collection('spots')
        .doc(id)
        .set(_makeSpotJson(map, spot, uid));
  }

  Future<void> updatePoint(MapInfo map, String spotId, Spot spot) async {
    map.spots[spotId] = spot;
    await _firestore
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
      'uid': uid != null ? _firestore.collection('users').doc(uid) : null,
      'point': GeoPoint(spot.point.latitude, spot.point.longitude),
      'score': spot.score,
      'photos': spot.photos
          .map((photo) => _firestore
              .collection('maps')
              .doc(map.id)
              .collection('photos')
              .doc(photo.key))
          .toList()
    };
  }

  Future<Spot> _makeSpot(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {bool shallow = false}) async {
    var data = snapshot.data()!;
    UserNameInfo? userNameInfo;
    if (!shallow && data['uid'] != null) {
      var userInfoData = (await data['uid'].get()).data();
      userNameInfo = UserNameInfo(data['uid'].id!, userInfoData['nickname']!);
    }

    List<Photo> photos = [];
    if (!shallow) {
      await Future.forEach(data['photos'], (dynamic doc) async {
        var photoSnapShot = await doc.get();
        photos.add(await _makePhoto(photoSnapShot.data()));
      });
    }

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

  Future<Photo> _makePhoto(Map<String, dynamic> json) async {
    var name = null;
    if (json['name'] != null) {
      var nameRef = (json['name'] as DocumentReference);
      dynamic nameData = (await nameRef.get()).data();
      if (nameData == null) {
        throw Exception("nameの参照に失敗しました photo.id: ${json['id']}");
      }

      var facePhoto = null;
      if (json['face_photo'] != null) {
        var facePhotoRef = (json['face_photo'] as DocumentReference);
        dynamic facePhotoData = (await facePhotoRef.get()).data();
        facePhoto = _makeName(facePhotoRef.id, facePhotoData);
      }

      var createdDate = nameData['created']?.toDate();

      name = Name(
          id: nameRef.id,
          name: nameData['name'] ?? '',
          pronounce: nameData['pronounce'] ?? '',
          created: createdDate,
          facePhoto: facePhoto);
    }

    return Photo(
        key: json['key'] ?? '',
        extension: json['extension'] ?? '',
        date: json['date']?.toDate(),
        uid: json['uid'] ?? '',
        name: name);
  }

  Name _makeName(String id, Map<String, dynamic> json) {
    return Name(
      id: id,
      name: json['name'] ?? '',
      pronounce: json['pronounce'] ?? '',
      place: json['place'] ?? '',
      memo: json['memo'] ?? '',
      facePhoto: json['face_photo'] != null
          ? FacePhoto.fromJson(json['face_photo'])
          : null,
      created: json['created']?.toDate(),
    );
  }
}
