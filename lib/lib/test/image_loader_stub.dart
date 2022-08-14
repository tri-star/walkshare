import 'dart:io';

import 'package:strollog/domain/map_info.dart';
import 'package:strollog/services/image_loader.dart';

class ImageLoaderFaceStub extends ImageLoaderFace {
  String? _imagePath;

  void setImagePath(String path) {
    _imagePath = path;
  }

  Future<File> loadImageWithCache(MapInfo map, String fileName) async {
    assert(_imagePath != null);
    return File.fromUri(Uri.file(_imagePath!));
  }
}
