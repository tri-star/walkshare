import 'package:flutter/foundation.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/repositories/map_info_repository.dart';

class AppStore with ChangeNotifier {
  MapInfo? currentMap;
  bool loading;
  final MapInfoRepository mapInfoRepository;

  AppStore(this.mapInfoRepository)
      : currentMap = null,
        loading = false;

  Future<void> loadMapInfo() async {
    if (loading) {
      return;
    }
    loading = true;
    notifyListeners();
    currentMap = await mapInfoRepository.fetchMapByName('cats');
    loading = false;
    notifyListeners();
  }
}
