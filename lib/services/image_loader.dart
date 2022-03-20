import 'package:firebase_storage/firebase_storage.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/photo.dart';

class ImageLoader {
  Future<String> getDownloadUrl(MapInfo map, Photo photo) async {
    var path = 'maps/${map.name}/${photo.getFileName()}';
    return await FirebaseStorage.instance.ref(path).getDownloadURL();
  }
}
