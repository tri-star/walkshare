import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/name_repository.dart';

class NameDetailPageStore with ChangeNotifier {
  String mapId;
  MapInfo? mapInfo;
  Name? name;
  final NameRepository nameRepository;
  final MapInfoRepository mapInfoRepository;

  NameDetailPageStore(this.nameRepository, this.mapInfoRepository)
      : mapId = '',
        name = null;

  Future<void> initialize(String mapId, String nameId) async {
    this.mapId = mapId;
    name = await nameRepository.fetchNameById(mapId, nameId);
    mapInfo = await mapInfoRepository.fetchMapMetaById(mapId);
    notifyListeners();
  }
}
