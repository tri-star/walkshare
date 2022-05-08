import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/services/auth_service.dart';

class PointAddFormStore extends ChangeNotifier {
  final MapInfoRepository _mapInfoRepository;
  final AuthService _authService;

  String _title = '';

  String _comment = '';

  final ImagePicker _picker;

  List<XFile> _photos = [];

  bool _saving = false;

  String get title => _title;
  String get comment => _comment;
  List<XFile> get photos => _photos;
  bool get saving => _saving;

  PointAddFormStore(this._mapInfoRepository, this._authService)
      : _picker = ImagePicker();

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void setComment(String comment) {
    _comment = comment;
    notifyListeners();
  }

  Future<void> save(MapInfo mapInfo, Position _position) async {
    var spot = Spot(_title, _position, comment: _comment);

    _saving = true;
    notifyListeners();

    var uploadedPhotos =
        await _mapInfoRepository.uploadPhotos(mapInfo, _photos);

    if (uploadedPhotos.length > 0) {
      spot.addPhotos(uploadedPhotos);
    }

    await _mapInfoRepository.addSpot(mapInfo, _authService.getUser().id, spot);
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

    return other is PointAddFormStore &&
        _title == other.title &&
        _comment == other.comment &&
        _photos == other.photos;
  }

  @override
  int get hashCode => hashValues(_title, _comment, _photos);
}
