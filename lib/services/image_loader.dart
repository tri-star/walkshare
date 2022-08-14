import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:http/http.dart' as http;

enum PhotoType { photo, face }

abstract class ImageLoader {
  final FirebaseStorage firebaseStorage;

  ImageLoader(this.firebaseStorage);

  Future<String> getDownloadUrl(MapInfo map, String fileName) async {
    var prefix = _photoDirPrefix(map);
    var path = '$prefix/$fileName';
    return await firebaseStorage.ref(path).getDownloadURL();
  }

  Future<File> loadImageWithCache(MapInfo map, String fileName) async {
    // ローカルに画像があればそれをロードして返す
    final cachePath = await _localCachePath(map, fileName);

    if (await File(cachePath).exists()) {
      return File(cachePath);
    }

    // ローカルにダウンロードする
    final downloadUrl = await getDownloadUrl(map, fileName);
    final response = await http.get(Uri.parse(downloadUrl));
    late File file;
    if (response.statusCode == 200) {
      file = File(cachePath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception(
          '画像のダウンロード中にエラーが発生しました。: status:${response.statusCode}, message:${response.reasonPhrase}');
    }

    //TODO: 何らかのタイミングでローカルのキャッシュで1週間以上経過したものを削除する
    return file;
  }

  Future<String> _localCachePath(MapInfo map, String fileName) async {
    final directory = await getTemporaryDirectory();

    var prefix = _photoDirPrefix(map);
    final cacheFileName = File(fileName);
    final String cacheDir =
        '${directory.path}/image_cache/${prefix}/${cacheFileName.parent}';
    if (!(await Directory(cacheDir).exists())) {
      await Directory(cacheDir).create(recursive: true);
    }

    final cachePath = '$cacheDir/$fileName';
    return cachePath;
  }

  /// 画像の種類に応じてパスが異なる
  String _photoDirPrefix(MapInfo map);
}

/// 写真用の画像をロードする
class ImageLoaderPhoto extends ImageLoader {
  ImageLoaderPhoto(FirebaseStorage firebaseStorage) : super(firebaseStorage);

  String _photoDirPrefix(MapInfo map) {
    return 'maps/${map.name}';
  }
}

/// 顔写真用の画像をロードする
class ImageLoaderFace extends ImageLoader {
  ImageLoaderFace(FirebaseStorage firebaseStorage) : super(firebaseStorage);

  String _photoDirPrefix(MapInfo map) {
    return 'maps/${map.name}/faces';
  }
}
