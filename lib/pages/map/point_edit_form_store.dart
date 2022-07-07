import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/photo_repository.dart';
import 'package:strollog/services/auth_service.dart';

class PointEditFormStore extends ChangeNotifier {
  final MapInfoRepository _mapInfoRepository;
  final PhotoRepository _photoRepository;
  final AuthService _authService;

  Spot? _originalSpot;

  late MapInfo _mapInfo;

  late String _spotId;

  String _title = '';

  String _comment = '';

  final ImagePicker _picker;

  List<XFile> _photos = [];

  bool _saving = false;

  String get title => _title;
  String get comment => _comment;
  List<XFile> get photos => _photos;
  bool get saving => _saving;

  PointEditFormStore(
      this._mapInfoRepository, this._photoRepository, this._authService)
      : _picker = ImagePicker();

  Future<void> initBySpotId(MapInfo mapInfo, String spotId) async {
    _mapInfo = mapInfo;
    _spotId = spotId;

    _originalSpot = await _mapInfoRepository.fetchSpot(mapInfo, spotId);
    _title = _originalSpot!.title;
    _comment = _originalSpot!.comment;
    _photos = [];
  }

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void setComment(String comment) {
    _comment = comment;
    notifyListeners();
  }

  Future<void> save() async {
    var point = _originalSpot!.point;
    var photos = _originalSpot!.photos;
    var newMapPoint = Spot(_title, point,
        comment: _comment,
        newDate: _originalSpot!.date,
        userNameInfo: _originalSpot!.userNameInfo);

    _saving = true;
    notifyListeners();

    var uid = _authService.getUser().id;
    var uploadedPhotos =
        await _photoRepository.uploadPhotos(_mapInfo, uid, _photos);

    newMapPoint.photos = photos;
    if (uploadedPhotos.length > 0) {
      newMapPoint.addPhotos(uploadedPhotos);
    }

    await _mapInfoRepository.updatePoint(_mapInfo, _spotId, newMapPoint);
    _title = '';
    _comment = '';
    _photos = [];
    _saving = false;
    notifyListeners();
  }

  bool isValidInput() {
    return _title.length > 0;
  }

  bool canSave() {
    return isValidInput() && !_saving;
  }

  Future<void> pickImage() async {
    List<XFile>? newPhotos = await _picker.pickMultiImage();
    if (newPhotos == null) {
      return;
    }
    _photos.addAll(newPhotos);
    notifyListeners();
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;

    return other is PointEditFormStore &&
        _title == other.title &&
        _comment == other.comment &&
        _photos == other.photos;
  }

  @override
  int get hashCode => hashValues(_title, _comment, _photos);
}
