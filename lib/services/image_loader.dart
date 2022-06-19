import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/photo.dart';
import 'package:http/http.dart' as http;

class ImageLoader {
  Future<String> getDownloadUrl(MapInfo map, Photo photo) async {
    var path = 'maps/${map.name}/${photo.getFileName()}';
    return await FirebaseStorage.instance.ref(path).getDownloadURL();
  }

  Future<File> loadImageWithCache(MapInfo map, Photo photo) async {
    // ローカルに画像があればそれをロードして返す
    final cachePath = await _localCachePath(map, photo);

    if (await File(cachePath).exists()) {
      return File(cachePath);
    }

    // ローカルにダウンロードする
    final downloadUrl = await getDownloadUrl(map, photo);
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

  Future<String> _localCachePath(MapInfo map, Photo photo) async {
    final directory = await getTemporaryDirectory();

    final cacheFileName = File(photo.getFileName());
    final String cacheDir =
        '${directory.path}/image_cache/maps/${map.id}/${cacheFileName.parent}';
    if (!(await Directory(cacheDir).exists())) {
      await Directory(cacheDir).create(recursive: true);
    }

    final cachePath = '$cacheDir/${photo.getFileName()}';
    return cachePath;
  }
}
