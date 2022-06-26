import 'package:flutter/material.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/repositories/name_repository.dart';

class NameAddPageStore with ChangeNotifier {
  String mapId;
  Name name;
  bool interacted;
  bool saving;
  NameRepository nameRepository;

  NameAddPageStore(this.nameRepository)
      : mapId = '',
        name = Name(name: '', pronounce: ''),
        interacted = false,
        saving = false;

  Future<void> initialize(String mapId) async {
    this.mapId = mapId;
    interacted = false;
    saving = false;
    name = Name(name: '', pronounce: '');
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
    nameRepository.save(null, mapId, name);
    saving = false;
    notifyListeners();
  }
}
