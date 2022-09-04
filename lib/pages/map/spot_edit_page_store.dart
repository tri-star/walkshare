import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/name_repository.dart';
import 'package:strollog/repositories/photo_repository.dart';
import 'package:strollog/services/auth_service.dart';
import 'package:strollog/services/image_loader.dart';

class SpotEditPageStore extends ChangeNotifier {
  final MapInfoRepository _mapInfoRepository;
  final PhotoRepository _photoRepository;
  final NameRepository _nameRepository;
  final AuthService _authService;
  final ImageLoaderPhoto _imageLoader;
  final ImagePicker _imagePicker;

  Spot? _originalSpot;

  late MapInfo _mapInfo;

  late String _spotId;

  String title = '';
  String comment = '';

  List<DraftPhoto> photos = [];

  List<Name> _nameList = [];
  String _nameFilter = '';

  bool _initialized = false;
  bool _interacted = false;
  bool _saving = false;

  bool get initialized => _initialized;
  bool get interacted => _interacted;
  bool get saving => _saving;

  SpotEditPageStore(
      this._mapInfoRepository,
      this._photoRepository,
      this._nameRepository,
      this._authService,
      this._imagePicker,
      this._imageLoader);

  Future<void> init(MapInfo mapInfo, String spotId) async {
    _initialized = false;
    _mapInfo = mapInfo;
    _spotId = spotId;

    _originalSpot = await _mapInfoRepository.fetchSpot(mapInfo, spotId);
    title = _originalSpot!.title;
    comment = _originalSpot!.comment;
    photos = await Future.wait(_originalSpot!.photos.map((savedPhoto) async {
      var cacheFile = await _imageLoader.loadImageWithCache(
          _mapInfo, savedPhoto.getFileName());
      return DraftPhoto.saved(savedPhoto, cachePath: cacheFile.path);
    }));

    _nameList = await _nameRepository.fetchNames(mapInfo.id!);
    _nameFilter = '';

    _initialized = true;
    notifyListeners();
  }

  void setInteracted(bool value) {
    _interacted = value;
    notifyListeners();
  }

  void setName(DraftPhoto draftPhoto, Name? name) {
    draftPhoto.name = name;
    setInteracted(true);
    notifyListeners();
  }

  void updateNameFilter(String newValue) {
    _nameFilter = newValue;
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

  Future<void> save() async {
    var point = _originalSpot!.point;
    // var originalPhotos = _originalSpot!.photos;
    var newSpot = Spot(title, point,
        comment: comment,
        newDate: _originalSpot!.date,
        userNameInfo: _originalSpot!.userNameInfo,
        lastVisited: _originalSpot!.lastVisited);

    _saving = true;
    notifyListeners();

    var uid = _authService.getUser().id;

    // 新しく選択された写真を保存する
    var uploadedPhotos =
        await _photoRepository.uploadPhotos(_mapInfo, uid, photos);
    newSpot.photos = uploadedPhotos;

    await _mapInfoRepository.updatePoint(_mapInfo, _spotId, newSpot);
    _saving = false;
    notifyListeners();
  }

  Future<void> pickImage() async {
    List<XFile>? newPhotos = await _imagePicker.pickMultiImage();
    if (newPhotos == null) {
      return;
    }
    photos.addAll(newPhotos.map((p) => DraftPhoto.draft(p)));
    setInteracted(true);
    notifyListeners();
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;

    return other is SpotEditPageStore &&
        title == other.title &&
        comment == other.comment &&
        photos == other.photos;
  }

  @override
  int get hashCode => hashValues(title, comment, photos);
}
