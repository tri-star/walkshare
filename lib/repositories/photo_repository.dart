import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/photo.dart';

class PhotoRepository {
  Future<List<Photo>> uploadPhotos(
      MapInfo map, String uid, List<DraftPhoto> draftPhotos) async {
    // CloudStorageにファイルをアップロードする
    // Photo形式に変換して返す
    List<Photo> photos = [];
    for (var draftPhoto in draftPhotos) {
      try {
        Photo photo;
        if (draftPhoto.isDraft()) {
          photo = Photo.fromPath(draftPhoto.file!.path, uid);
          var path = "maps/${map.name}/${photo.getFileName()}";
          await FirebaseStorage.instance
              .ref(path)
              .putFile(File(draftPhoto.file!.path));
        } else {
          photo = draftPhoto.savedPhoto!;
        }

        // 新しく設定された名前は draftPhoto.nameに記録されている
        photo.name = draftPhoto.name;

        await FirebaseFirestore.instance
            .collection('maps')
            .doc(map.id)
            .collection('photos')
            .doc(photo.key)
            .set(_toJson(map.id!, photo));

        photos.add(photo);
      } on FirebaseException catch (e) {
        FirebaseCrashlytics.instance.recordError(e, e.stackTrace);
      }
    }
    return photos;
  }

  Map<String, Object?> _toJson(String mapId, Photo photo) {
    return {
      'key': photo.key,
      'extension': photo.extension,
      'name': photo.name == null
          ? null
          : FirebaseFirestore.instance
              .collection('maps')
              .doc(mapId)
              .collection('names')
              .doc(photo.name!.id),
      'date': photo.date,
      'uid': photo.uid,
    };
  }
}
