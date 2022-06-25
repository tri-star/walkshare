import 'package:flutter/foundation.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/repositories/name_repository.dart';

enum LoadState { neutral, loading, loaded }

class NameListPageStore with ChangeNotifier {
  List<Name> names = [];
  LoadState loadState = LoadState.neutral;
  String mapId = '';
  final NameRepository nameRepository;

  NameListPageStore(this.nameRepository);

  void initialize(String mapId) {
    this.mapId = mapId;
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
