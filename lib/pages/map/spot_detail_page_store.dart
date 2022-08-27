import 'package:flutter/cupertino.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/repositories/map_info_repository.dart';

class SpotDetailPageStore with ChangeNotifier {
  final MapInfoRepository mapInfoRepository;
  late MapInfo mapInfo;
  late Spot spot;

  SpotDetailPageStore(this.mapInfoRepository);

  void init(MapInfo mapInfo, Spot spot) {
    this.mapInfo = mapInfo;
    this.spot = spot;
  }

  Future<void> setLastVisited(DateTime? date) async {
    if (date == null) {
      return;
    }
    spot.lastVisited = date;
    await mapInfoRepository.updateLastVisited(mapInfo, spot.id, date);
    notifyListeners();
  }
}
