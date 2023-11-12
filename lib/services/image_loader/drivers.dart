import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:strollog/config.dart';

abstract class ImageLoaderDriver {
  Future<Uint8List> loadFile(String path);
}

abstract class ThumbnailLoaderDriver {
  Future<Uint8List> loadFile(String path, int size);
}

class ImageLoaderStorageDriver implements ImageLoaderDriver {
  final FirebaseStorage firebaseStorage;

  ImageLoaderStorageDriver(this.firebaseStorage);

  @override
  Future<Uint8List> loadFile(String path) async {
    final downloadUrl = await firebaseStorage.ref(path).getDownloadURL();
    final response = await http.get(Uri.parse(downloadUrl));
    if (response.statusCode != 200) {
      throw Exception(
          '画像のダウンロード中にエラーが発生しました。: status:${response.statusCode}, message:${response.reasonPhrase}');
    }
    return response.bodyBytes;
  }
}

/// サムネイル取得用APIから画像をロードする
class ImageLoaderThumbnailApiDriver extends ThumbnailLoaderDriver {
  ImageLoaderThumbnailApiDriver();

  @override
  Future<Uint8List> loadFile(String path, int size) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final token = await user?.getIdTokenResult();
    final Uri requestUri = Uri(
      scheme: 'https',
      host:
          '${Config().firebaseRegion}-${Config().firebaseProjectId}.cloudfunctions.net',
      path: '/generateThumbnail',
      queryParameters: {
        'key': path,
        'w': size.toString(),
      },
    );
    final response = await http.get(requestUri, headers: {
      'Authorization': 'Bearer ${token?.token ?? ""}',
    });
    if (response.statusCode != 200) {
      throw Exception(
          '画像のダウンロード中にエラーが発生しました。: path: ${path}, status:${response.statusCode}, message:${response.reasonPhrase}');
    }
    return response.bodyBytes;
  }
}
