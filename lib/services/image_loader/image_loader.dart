import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/services/image_loader/drivers.dart';
import 'package:path/path.dart' as p;

/// リサイズなしの実寸の画像をロードする
class PhotoImageLoader {
  final ImageLoaderDriver _driver;

  PhotoImageLoader(this._driver);

  Future<String> load(MapInfo map, String fileName) async {
    final cachePath = await _buildLocalCachePath(map, fileName);

    if (File(cachePath).existsSync()) {
      return cachePath;
    }

    final remotePath = _buildPath(map, fileName);
    final data = await _driver.loadFile(remotePath);

    final localCache = File(cachePath);
    await localCache.writeAsBytes(data);

    return localCache.path;
  }

  /// リモート上のパスを構築する
  String _buildPath(MapInfo map, String fileName) {
    var prefixParts = ['maps', map.name];
    return p.joinAll([...prefixParts, fileName]);
  }

  /// ローカルキャッシュ用のパスを構築する
  Future<String> _buildLocalCachePath(MapInfo map, String fileName) async {
    final directory = await getTemporaryDirectory();

    // filePath = maps/cats/xxxx.jpg という形式
    final filePath = _buildPath(map, fileName);
    final String cacheDir =
        p.joinAll([directory.path, 'image_cache', p.dirname(filePath)]);
    if (!(await Directory(cacheDir).exists())) {
      await Directory(cacheDir).create(recursive: true);
    }

    final cachePath = p.join(cacheDir, fileName);
    return cachePath;
  }
}

/// 写真のサムネイルをロードする
class PhotoThumbnailImageLoader {
  final ThumbnailLoaderDriver _driver;

  PhotoThumbnailImageLoader(this._driver);

  Future<String> load(MapInfo map, String fileName, int size) async {
    final cachePath = await _buildLocalCachePath(map, fileName, size);

    if (File(cachePath).existsSync()) {
      return cachePath;
    }

    final remotePath = _buildPath(map, fileName);
    final data = await _driver.loadFile(remotePath, size);

    final localCache = File(cachePath);
    await localCache.writeAsBytes(data);

    return localCache.path;
  }

  /// リモート上のパスを構築する
  String _buildPath(MapInfo map, String fileName) {
    var prefixParts = ['maps', map.name];
    return p.joinAll([...prefixParts, fileName]);
  }

  /// ローカルキャッシュ上のパスを構築する
  Future<String> _buildLocalCachePath(
      MapInfo map, String fileName, int size) async {
    final directory = await getTemporaryDirectory();

    // filePath = maps/cats/xxxx.jpg という形式
    final filePath = _buildPath(map, fileName);
    final String cacheDir =
        p.joinAll([directory.path, 'thumbnail_cache', p.dirname(filePath)]);
    if (!(await Directory(cacheDir).exists())) {
      await Directory(cacheDir).create(recursive: true);
    }

    final cachePath = p.join(cacheDir, fileName);
    return cachePath;
  }
}

/// 顔写真用の画像をロードする
class FacePhotoImageLoader {
  final ImageLoaderDriver _driver;

  FacePhotoImageLoader(this._driver);

  Future<String> load(MapInfo map, String fileName) async {
    final cachePath = await _buildLocalCachePath(map, fileName);

    if (File(cachePath).existsSync()) {
      return cachePath;
    }

    final remotePath = _buildPath(map, fileName);
    final data = await _driver.loadFile(remotePath);

    final localCache = File(cachePath);
    await localCache.writeAsBytes(data);

    return localCache.path;
  }

  /// リモート上のパスを構築する
  String _buildPath(MapInfo map, String fileName) {
    var prefixParts = ['maps', map.name, 'faces'];
    return p.joinAll([...prefixParts, fileName]);
  }

  /// ローカルキャッシュ用のパスを構築する
  Future<String> _buildLocalCachePath(MapInfo map, String fileName) async {
    final directory = await getTemporaryDirectory();

    // filePath = maps/cats/xxxx.jpg という形式
    final filePath = _buildPath(map, fileName);
    final String cacheDir =
        p.joinAll([directory.path, 'image_cache', p.dirname(filePath)]);
    if (!(await Directory(cacheDir).exists())) {
      await Directory(cacheDir).create(recursive: true);
    }

    final cachePath = p.join(cacheDir, fileName);
    return cachePath;
  }
}
