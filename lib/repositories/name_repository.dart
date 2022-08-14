import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:strollog/domain/face_photo.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/domain/user.dart';

class NameRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage firebaseStorage;

  NameRepository(this.firestore, this.firebaseStorage);

  Future<void> save(User? user, String mapId, Name name) async {
    var json = {
      'name': name.name,
      'pronounce': name.pronounce,
      'place': name.place,
      'memo': name.memo,
      'face_photo': name.facePhoto != null
          ? {
              'key': name.facePhoto!.key,
              'extension': name.facePhoto!.extension,
              'date': name.facePhoto!.date,
            }
          : null,
      'created': name.created
    };
    await firestore
        .collection('maps')
        .doc(mapId)
        .collection('names')
        .doc(name.id)
        .set(json);
  }

  Future<List<Name>> fetchNames(String mapId, {String order = 'latest'}) async {
    var orderField = order == 'latest' ? 'created' : 'pronounce';
    var query = firestore.collection('maps').doc(mapId).collection('names');

    // if (order == 'latest') {
    //   query.orderBy('created', descending: true);
    // } else if (order == 'name') {
    //   query.orderBy('pronounce');
    // }

    var documents = await query.get(const GetOptions(source: Source.server));

    List<Name> result = documents.docs.map((document) {
      return _makeName(document.id, document.data());
    }).toList();

    return result;
  }

  Future<Name?> fetchNameById(String mapId, String nameId) async {
    var document = await firestore
        .collection('maps')
        .doc(mapId)
        .collection('names')
        .doc(nameId)
        .get(const GetOptions(source: Source.server));

    if (!document.exists) {
      return null;
    }

    return _makeName(document.id, document.data()!);
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

  Future<FacePhoto> uploadPhoto(MapInfo map, File file) async {
    // CloudStorageにファイルをアップロードする
    // Photo形式に変換して返す
    try {
      var photo = FacePhoto.fromPath(file.path);
      var path = "maps/${map.name}/faces/${photo.getFileName()}";
      await firebaseStorage.ref(path).putFile(File(file.path));

      return photo;
    } on FirebaseException catch (e) {
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace);
      rethrow;
    }
  }
}
