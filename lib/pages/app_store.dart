import 'package:flutter/foundation.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/repositories/map_info_repository.dart';

class AppStore with ChangeNotifier {
  MapInfo? currentMap;
  Map<String, MapInfo>? mapList;
  bool loading;
  final MapInfoRepository mapInfoRepository;

  AppStore(this.mapInfoRepository)
      : currentMap = null,
        mapList = null,
        loading = false;

  Future<void> loadMapInfo() async {
    if (loading) {
      return;
    }
    loading = true;
    notifyListeners();
    mapList = await mapInfoRepository.fetchMapMetaList();
    currentMap = await mapInfoRepository.fetchMapByName('cats');
    loading = false;
    notifyListeners();
  }

  MapInfo? getMapInfo(String id) {
    return mapList![id];
  }
}
