import 'package:flutter/widgets.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/repositories/map_info_repository.dart';

class PointAddFormStore extends ChangeNotifier {
  final MapInfoRepository _mapInfoRepository;

  String _title = '';

  String _comment = '';

  String get title => _title;
  String get comment => _comment;

  PointAddFormStore(this._mapInfoRepository);

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
    notifyListeners();
  }

  bool isValidInput() {
    return _title.length > 0;
  }
}
