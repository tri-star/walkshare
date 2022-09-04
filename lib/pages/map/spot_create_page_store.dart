import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/name_repository.dart';
import 'package:strollog/repositories/photo_repository.dart';
import 'package:strollog/services/auth_service.dart';

class SpotCreatePageStore extends ChangeNotifier {
  final MapInfoRepository _mapInfoRepository;
  final PhotoRepository _photoRepository;
  final NameRepository _nameRepository;
  final AuthService _authService;
  final ImagePicker _picker;

  late MapInfo mapInfo;
  late Position _position;

  String title = '';
  String comment = '';

  List<DraftPhoto> _photos = [];

  List<Name> _nameList = [];
  String _nameFilter = '';

  bool _interacted = false;
  bool _saving = false;

  List<DraftPhoto> get photos => _photos;
  bool get interacted => _interacted;
  bool get saving => _saving;

  SpotCreatePageStore(this._mapInfoRepository, this._photoRepository,
      this._nameRepository, this._authService, this._picker);

  Future<void> initialize(MapInfo mapInfo, Position position) async {
    this.mapInfo = mapInfo;
    _position = position;

    title = '';
    comment = '';
    _photos = [];
    _nameList = await _nameRepository.fetchNames(this.mapInfo.id!);
    _nameFilter = '';
  }

  void setName(DraftPhoto draftPhoto, Name? name) {
    draftPhoto.name = name;
    setInteracted(true);
    notifyListeners();
  }

  void setInteracted(bool value) {
    _interacted = value;
    notifyListeners();
  }

  Future<Spot> save() async {
    var spot = Spot(title, _position, comment: comment);

    _saving = true;
    notifyListeners();

    var uid = _authService.getUser().id;
    var uploadedPhotos =
        await _photoRepository.uploadPhotos(mapInfo, uid, _photos);

    if (uploadedPhotos.isNotEmpty) {
      spot.addPhotos(uploadedPhotos);
    }

    await _mapInfoRepository.addSpot(mapInfo, _authService.getUser().id, spot);
    title = '';
    comment = '';
    _photos = [];
    _saving = false;

    notifyListeners();

    return spot;
  }

  String get nameFilter => _nameFilter;

  void updateNameFilter(String filter) {
    _nameFilter = filter;
    notifyListeners();
  }

  List<Name> getFilteredNames() {
    return _nameList.where((name) {
      if (_nameFilter == '') {
        return true;
      }
      return name.pronounce.contains(_nameFilter);
    }).toList();
  }

  String? validateTitle(String? value) {
    if (value == null || value == '') {
      return 'タイトルを入力してください';
    }
    return null;
  }

  bool canSave() {
    return _interacted && !_saving;
  }

  Future<void> pickImage() async {
    List<XFile>? newPhotos = await _picker.pickMultiImage();
    if (newPhotos == null) {
      return;
    }
    _photos.addAll(newPhotos.map((e) => DraftPhoto.draft(e)));
    setInteracted(true);
    notifyListeners();
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;

    return other is SpotCreatePageStore &&
        title == other.title &&
        comment == other.comment &&
        _photos == other.photos;
  }

  @override
  int get hashCode => hashValues(title, comment, _photos);
}
