import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/repositories/map_info_repository.dart';

class PointAddFormStore extends ChangeNotifier {
  final MapInfoRepository _mapInfoRepository;

  String _title = '';

  String _comment = '';

  final ImagePicker _picker;

  List<XFile> _photos = [];

  String get title => _title;
  String get comment => _comment;
  List<XFile> get photos => _photos;

  PointAddFormStore(this._mapInfoRepository) : _picker = ImagePicker();

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void setComment(String comment) {
    _comment = comment;
    notifyListeners();
  }

  Future<void> save(MapInfo mapInfo, Position _position) async {
    var mapPoint = MapPoint(_title, _position, comment: _comment);
    await _mapInfoRepository.addPoint(mapInfo, mapPoint);
    _title = '';
    _comment = '';
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

    return other is PointAddFormStore &&
        _title == other.title &&
        _comment == other.comment;
  }

  @override
  int get hashCode => hashValues(_title, _comment);
}
