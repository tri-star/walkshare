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
    final path = _buildPath(map, fileName);
    final cachePath = await _buildLocalCachePath(map, fileName);

    if (File(cachePath).existsSync()) {
      return cachePath;
    }

    final data = await _driver.loadFile(path);

    final file = File(cachePath);
    await file.writeAsBytes(data);

    return file.path;
  }

  String _buildPath(MapInfo map, String fileName) {
    var prefixParts = ['maps', map.name];
    return p.joinAll([...prefixParts, fileName]);
  }

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
    final path = _buildPath(map, fileName);
    final cachePath = await _buildLocalCachePath(map, fileName, size);

    if (File(cachePath).existsSync()) {
      return cachePath;
    }

    final data = await _driver.loadFile(path, size);

    final file = File(cachePath);
    await file.writeAsBytes(data);

    return file.path;
  }

  String _buildPath(MapInfo map, String fileName) {
    var prefixParts = ['maps', map.name];
    return p.joinAll([...prefixParts, fileName]);
  }

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
