import 'package:flutter/material.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/repositories/name_repository.dart';

class NameAddPageStore with ChangeNotifier {
  String mapId;
  Name name;
  bool initialized = false;
  bool saving;
  NameRepository nameRepository;

  NameAddPageStore(this.nameRepository)
      : mapId = '',
        name = Name(name: '', pronounce: ''),
        initialized = false,
        saving = false;

  Future<void> initialize(String mapId) async {
    initialized = true;
    this.mapId = mapId;
    name = Name(name: '', pronounce: '');
  }

  FormFieldValidator<String>? getValidator(String field) {
    switch (field) {
      case 'name':
        return validateName;
      case 'pronounce':
        return validatePronounce;
      default:
        return null;
    }
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

  Future<void> save() async {
    saving = true;
    notifyListeners();
    nameRepository.save(null, mapId, name);
    saving = false;
    notifyListeners();
  }
}
