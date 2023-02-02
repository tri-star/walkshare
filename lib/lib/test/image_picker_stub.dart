import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerStub extends ImagePicker {
  List<String> _imagePaths = [];

  void setImage(String path) {
    _imagePaths = [path];
  }

  void setImages(List<String> paths) {
    _imagePaths = paths;
  }

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    if (_imagePaths.isEmpty) {
      return null;
    }
    var imageFile = File(_imagePaths[0]);
    var buffer = await imageFile.readAsBytes();
    return XFile(
      imageFile.path,
      name: imageFile.uri.pathSegments.last,
      length: buffer.length,
      bytes: buffer,
    );
  }

  @override
  Future<List<XFile>> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestFullMetadata = true,
  }) async {
    if (_imagePaths.isEmpty) {
      return [];
    }
    return Future.wait(_imagePaths.map((path) async {
      var imageFile = File(_imagePaths[0]);
      var buffer = await imageFile.readAsBytes();
      return XFile(
        imageFile.path,
        name: imageFile.uri.pathSegments.last,
        length: buffer.length,
        bytes: buffer,
      );
    }));
  }
}
