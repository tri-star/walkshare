import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:strollog/components/map_view.dart';
import 'package:strollog/domain/location_permission_result.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/domain/stroll_route.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/route_repository.dart';
import 'package:strollog/services/auth_service.dart';
import 'package:strollog/services/location_service.dart';

class MapPageStore extends ChangeNotifier {
  final AuthService _authService;
  final LocationService _locationService;
  final RouteRepository _routeRepository;
  final MapInfoRepository _mapInfoRepository;

  bool _locationRequested = false;
  Position? _position;
  MapController? _mapController;
  final StrollRoute _strollRoute;
  MapInfo? _mapInfo;

  MapPageStore(this._authService, this._locationService, this._routeRepository,
      this._mapInfoRepository)
      : _strollRoute = StrollRoute('route_' + DateTime.now().toString());

  bool get locationRequested => _locationRequested;
  Position? get position => _position;
  StrollRoute get strollRoute => _strollRoute;
  MapInfo? get mapInfo => _mapInfo;

  setLocationRequested(bool requested) {
    _locationRequested = requested;
    notifyListeners();
  }

  setLocation(Position position) {
    _position = position;
    notifyListeners();
  }

  setMapController(MapController mapController) {
    _mapController = mapController;
  }

  Future<void> init() async {
    var user = _authService.getUser();
    //await _routeRepository.save(user, _strollRoute);
    _mapInfo = await _mapInfoRepository.fetchMapByName('cats');

    if (!_locationRequested) {
      var permission = await requestLocationPermission();
      if (permission == LocationPermissionResult.deniedForever) {
        //return const Center(child: Text("位置情報の使用が拒否されています。"));
        // 現在位置は取得できないので、デフォルトの座標を取得する。
        // 最初のスポットか、それがない場合は110-0001あたりにする
        _position = null;
        if (_mapInfo?.spots.entries.isNotEmpty ?? false) {
          _position = _mapInfo?.spots.entries.first.value.point;
        } else {
          _position = Position(35.723605, 139.768156);
        }
        return;
      }

      // 位置情報の追跡を行う場合はここで現在地を求めると停止してしまうので、開始場所は別途検討する
      updateLocation();
    }
  }

  /// 位置情報の権限を確認、必要に応じて権限の取得を求める
  Future<LocationPermissionResult> requestLocationPermission() async {
    _locationRequested = true;
    var permission = await _locationService.checkPermission();
    if (permission == LocationPermissionResult.denied) {
      permission = await _locationService.requestPermission();
    }

    // listenLocation();
    // var user = _authService.getUser();
    // await _routeRepository.save(user, _strollRoute);

    notifyListeners();
    return permission;
  }

  Future<void> updateLocation() async {
    if (!_locationRequested) {
      throw UnsupportedError("予期しない呼び出しです");
    }

    _position = await _locationService.getCurrentPosition();
    _mapController?.move(_position!);
    notifyListeners();
  }

  Future<void> listenLocation() async {
    if (!_locationRequested) {
      throw UnsupportedError("予期しない呼び出しです2");
    }

    _locationService.listen((position) {
      _position = position;
      _strollRoute.addRoutePoint(position);
      _mapController?.move(_position!);
      _routeRepository.pushPoints(_strollRoute.id, [_position!]);

      notifyListeners();
    });
  }

  Future<void> reloadSpot(String spotId) async {
    var spot = await _mapInfoRepository.fetchSpot(mapInfo!, spotId);
    mapInfo!.spots[spotId] = spot;
    _mapController?.move(spot.point);
    notifyListeners();
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;

    return other is MapPageStore &&
        _locationRequested == other._locationRequested &&
        _position == other._position &&
        _mapController == other._mapController &&
        _strollRoute == other._strollRoute;
  }

  @override
  int get hashCode =>
      hashValues(_locationRequested, _position, _mapController, _strollRoute);
}
