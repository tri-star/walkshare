import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:http/http.dart' as http;

enum PhotoType { photo, face }

abstract class ImageLoader {
  final FirebaseStorage firebaseStorage;
  final FirebaseStorageDownloader downloader;

  ImageLoader(this.firebaseStorage, this.downloader);

  Future<File> loadImageWithCache(MapInfo map, String fileName) async {
    // ローカルに画像があればそれをロードして返す
    final cachePath = await _localCachePath(map, fileName);

    if (await File(cachePath).exists()) {
      return File(cachePath);
    }

    // ローカルにダウンロードする
    var key = [..._photoDirPrefixParts(map), fileName].join('/');
    await downloader.download(map, key, cachePath);

    //TODO: 何らかのタイミングでローカルのキャッシュで1週間以上経過したものを削除する
    return File(cachePath);
  }

  Future<String> _localCachePath(MapInfo map, String fileName) async {
    final directory = await getTemporaryDirectory();

    var prefixParts = _photoDirPrefixParts(map);
    final String cacheDir =
        p.joinAll([directory.path, 'image_cache', ...prefixParts]);
    if (!(await Directory(cacheDir).exists())) {
      await Directory(cacheDir).create(recursive: true);
    }

    final cachePath = p.join(cacheDir, fileName);
    return cachePath;
  }

  /// 画像の種類に応じてパスが異なる
  List<String> _photoDirPrefixParts(MapInfo map);
}

/// 写真用の画像をロードする
class ImageLoaderPhoto extends ImageLoader {
  ImageLoaderPhoto(
      FirebaseStorage firebaseStorage, FirebaseStorageDownloader downloader)
      : super(firebaseStorage, downloader);

  @override
  List<String> _photoDirPrefixParts(MapInfo map) {
    return ['maps', map.name];
  }
}

/// 顔写真用の画像をロードする
class ImageLoaderFace extends ImageLoader {
  ImageLoaderFace(
      FirebaseStorage firebaseStorage, FirebaseStorageDownloader downloader)
      : super(firebaseStorage, downloader);

  @override
  List<String> _photoDirPrefixParts(MapInfo map) {
    return ['maps', map.name, 'faces'];
  }
}

class FirebaseStorageDownloader {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageDownloader(this.firebaseStorage);

  Future<void> download(MapInfo map, String key, String cachePath) async {
    final downloadUrl = await firebaseStorage.ref(key).getDownloadURL();
    final response = await http.get(Uri.parse(downloadUrl));
    late File file;
    if (response.statusCode == 200) {
      file = File(cachePath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception(
          '画像のダウンロード中にエラーが発生しました。: status:${response.statusCode}, message:${response.reasonPhrase}');
    }
  }
}

class FirebaseStorageDownloaderStub extends FirebaseStorageDownloader {
  FirebaseStorageDownloaderStub(FirebaseStorage firebaseStorage)
      : super(firebaseStorage);

  @override
  Future<void> download(MapInfo map, String key, String cachePath) async {
    var outFile = File(cachePath);

    var buffer = await firebaseStorage.ref(key).getData();
    await outFile.writeAsBytes(buffer!);
  }
}
