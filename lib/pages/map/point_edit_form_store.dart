import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/repositories/map_info_repository.dart';

class PointEditFormStore extends ChangeNotifier {
  final MapInfoRepository _mapInfoRepository;

  late MapInfo _mapInfo;

  late int _index;

  String _title = '';

  String _comment = '';

  final ImagePicker _picker;

  List<XFile> _photos = [];

  String get title => _title;
  String get comment => _comment;
  List<XFile> get photos => _photos;

  PointEditFormStore(this._mapInfoRepository) : _picker = ImagePicker();

  Future<void> initByIndex(MapInfo mapInfo, int index) async {
    _mapInfo = mapInfo;
    _index = index;

    var mapPoint = _mapInfo.spots[_index];
    _title = mapPoint.title;
    _comment = mapPoint.comment;
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
    var point = _mapInfo.spots[_index].point;
    var photos = _mapInfo.spots[_index].photos;
    var newMapPoint = Spot(_title, point,
        comment: _comment, newDate: _mapInfo.spots[_index].date);
    var uploadedPhotos =
        await _mapInfoRepository.uploadPhotos(_mapInfo, _photos);

    newMapPoint.photos = photos;
    if (uploadedPhotos.length > 0) {
      newMapPoint.addPhotos(uploadedPhotos);
    }

    await _mapInfoRepository.updatePoint(_mapInfo, _index, newMapPoint);
    _title = '';
    _comment = '';
    _photos = [];
    notifyListeners();
  }

  bool isValidInput() {
    return _title.length > 0;
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
