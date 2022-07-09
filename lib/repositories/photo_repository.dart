import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/photo.dart';

class PhotoRepository {
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

        await FirebaseFirestore.instance
            .collection('maps')
            .doc(map.id)
            .collection('photos')
            .doc(photo.key)
            .set(photo.toJson());

        photos.add(photo);
      } on FirebaseException catch (e) {
        FirebaseCrashlytics.instance.recordError(e, e.stackTrace);
      }
    }
    return photos;
  }
}
