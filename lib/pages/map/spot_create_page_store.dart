import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/photo_repository.dart';
import 'package:strollog/services/auth_service.dart';

class SpotCreatePageStore extends ChangeNotifier {
  final MapInfoRepository _mapInfoRepository;
  final PhotoRepository _photoRepository;
  final AuthService _authService;

  String title = '';
  String comment = '';

  final ImagePicker _picker;

  List<XFile> _photos = [];

  bool _interacted = false;
  bool _saving = false;

  List<XFile> get photos => _photos;
  bool get interacted => _interacted;
  bool get saving => _saving;

  SpotCreatePageStore(
      this._mapInfoRepository, this._photoRepository, this._authService)
      : _picker = ImagePicker();

  void initialize() {
    title = '';
    comment = '';
    _photos = [];
  }

  void setInteracted(bool value) {
    _interacted = value;
    notifyListeners();
  }

  Future<Spot> save(MapInfo mapInfo, Position _position) async {
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
    _photos.addAll(newPhotos);
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
