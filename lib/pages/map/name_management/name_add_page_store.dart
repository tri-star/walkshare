import 'package:flutter/material.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/repositories/name_repository.dart';

class NameAddPageStore with ChangeNotifier {
  String mapId;
  Name name;
  bool initialized = false;
  bool canSave;
  bool saving;
  NameRepository nameRepository;

  NameAddPageStore(this.nameRepository)
      : mapId = '',
        name = Name(name: '', pronounce: ''),
        initialized = false,
        canSave = false,
        saving = false;

  Future<void> initialize(String mapId, VoidCallback onInitialize) async {
    if (initialized) {
      return;
    }
    initialized = true;
    this.mapId = mapId;
    name = Name(name: '', pronounce: '');

    onInitialize.call();
  }

  void setName(String newName) {
    name.name = newName;
    validate();
  }

  void setPronounce(String newPronounce) {
    name.pronounce = newPronounce;
    validate();
  }

  Future<void> validate() async {
    if (name.name == '') {
      canSave = false;
    } else if (name.pronounce == '') {
      canSave = false;
    } else {
      canSave = true;
    }
    notifyListeners();
  }

  Future<void> save() async {
    nameRepository.save(null, mapId, name);
  }
}
