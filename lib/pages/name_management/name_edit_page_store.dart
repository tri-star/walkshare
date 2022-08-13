import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/face_photo.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/name_repository.dart';

class NameEditPageStore with ChangeNotifier {
  String mapId;
  String nameId;
  Name name;
  CroppedFile? croppedPhoto;
  bool interacted;
  bool saving;
  final NameRepository nameRepository;
  final MapInfoRepository mapInfoRepository;
  final ImagePicker imagePicker;
  final ImageCropper imageCropper;

  NameEditPageStore(this.nameRepository, this.mapInfoRepository,
      this.imagePicker, this.imageCropper)
      : mapId = '',
        nameId = '',
        name = Name(name: '', pronounce: ''),
        interacted = false,
        saving = false;

  Future<void> initialize(String mapId, String nameId) async {
    this.mapId = mapId;
    this.nameId = nameId;
    interacted = false;
    saving = false;
    croppedPhoto = null;
    name = Name(name: '', pronounce: '');
  }

  Future<void> pickImage() async {
    var pickedPhoto = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedPhoto == null) {
      return;
    }

    var cropped = await imageCropper.cropImage(
        sourcePath: pickedPhoto.path,
        compressFormat: ImageCompressFormat.png,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        maxWidth: 500,
        maxHeight: 500,
        uiSettings: [
          AndroidUiSettings(toolbarTitle: '写真の切り抜き', lockAspectRatio: true),
          IOSUiSettings(title: '写真の切り抜き', aspectRatioLockEnabled: true),
        ]);

    if (cropped == null) {
      return;
    }

    croppedPhoto = cropped;
    notifyListeners();
  }

  String? validateName(String? value) {
    if (value == null || value == '') {
      return '名前を入力してください';
    }
    return null;
  }

  String? validatePronounce(String? value) {
    if (value == null || value == '') {
      return '読みを入力してください';
    }
    return null;
  }

  void setInteracted(bool value) {
    interacted = value;
    notifyListeners();
  }

  Future<void> save() async {
    saving = true;
    notifyListeners();

    var mapInfo = await mapInfoRepository.fetchMapMetaById(mapId);
    if (mapInfo == null) {
      throw UnsupportedError('無効なマップが指定されました。id:${mapId}');
    }

    if (croppedPhoto != null) {
      name.facePhoto =
          await nameRepository.uploadPhoto(mapInfo, File(croppedPhoto!.path));
    }

    nameRepository.save(null, mapId, name);
    saving = false;
    notifyListeners();
  }
}
