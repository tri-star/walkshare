import 'package:flutter/foundation.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/name_repository.dart';

enum LoadState { neutral, loading, loaded }

class NameListPageStore with ChangeNotifier {
  List<Name> names = [];
  LoadState loadState = LoadState.neutral;
  String mapId = '';
  MapInfo? mapInfo;
  final NameRepository nameRepository;
  final MapInfoRepository mapInfoRepository;

  NameListPageStore(this.nameRepository, this.mapInfoRepository);

  Future<void> initialize(String mapId) async {
    this.mapId = mapId;
    mapInfo = await mapInfoRepository.fetchMapMetaById(mapId);
  }

  Future<void> loadList() async {
    assert(mapId != '');
    loadState = LoadState.loading;
    notifyListeners();
    names = await nameRepository.fetchNames(mapId);
    loadState = LoadState.loaded;
    notifyListeners();
  }
}
