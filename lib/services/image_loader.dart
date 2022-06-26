import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:http/http.dart' as http;

enum PhotoType { photo, face }

class ImageLoader {
  final PhotoType type;

  ImageLoader(this.type);

  Future<String> getDownloadUrl(MapInfo map, String fileName) async {
    var prefix = _photoDirPrefix(map, type);
    var path = '$prefix/$fileName';
    return await FirebaseStorage.instance.ref(path).getDownloadURL();
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

    var prefix = _photoDirPrefix(map, type);
    final cacheFileName = File(fileName);
    final String cacheDir =
        '${directory.path}/image_cache/${prefix}/${cacheFileName.parent}';
    if (!(await Directory(cacheDir).exists())) {
      await Directory(cacheDir).create(recursive: true);
    }

    final cachePath = '$cacheDir/$fileName';
    return cachePath;
  }

  String _photoDirPrefix(MapInfo map, PhotoType type) {
    switch (type) {
      case PhotoType.photo:
        return 'maps/${map.name}';
      case PhotoType.face:
        return 'maps/${map.name}/faces';
    }
  }
}
