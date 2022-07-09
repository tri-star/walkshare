import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/domain/stroll_route.dart';
import 'package:strollog/pages/map/spot_create_page_store.dart';

typedef LongTapCallBack = Future<void> Function(Position position);
typedef MapPointTapCallBack = void Function(String spotId);

class MapView extends StatelessWidget {
  final Position _initialPosition;
  final MapController _controller;
  final StrollRoute _strollRoute;
  final MapInfo? _mapInfo;
  final LongTapCallBack? _longTapCallBack;
  final MapPointTapCallBack? _mapPointTapCallBack;
  final Map<String, Spot>? _spots;

  const MapView(MapController controller, Position initialPosition,
      StrollRoute strollRoute, MapInfo? mapInfo, Map<String, Spot>? spots,
      {LongTapCallBack? onLongTap, MapPointTapCallBack? onPointTap, Key? key})
      : _controller = controller,
        _initialPosition = initialPosition,
        _strollRoute = strollRoute,
        _mapInfo = mapInfo,
        _spots = spots,
        _longTapCallBack = onLongTap,
        _mapPointTapCallBack = onPointTap,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<SpotCreatePageStore>(context, listen: false);
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(_initialPosition.latitude, _initialPosition.longitude),
        zoom: 15,
      ),
      myLocationEnabled: true, // 後でON/OFFできる必要がある
      onCameraMove: _onCameraMove,
      onLongPress: (LatLng newPos) {
        if (_longTapCallBack != null) {
          _longTapCallBack!(Position(newPos.latitude, newPos.longitude));
        }
      },
      polylines: [_makePolyLines(_strollRoute.routePoints)].toSet(),
      markers: _makeMarkers().toSet(),
    );
  }

  _onMapCreated(GoogleMapController googleMapController) {
    _controller.subscribe(googleMapController);
  }

  _onCameraMove(CameraPosition cameraPosition) {}

  Polyline _makePolyLines(List<Position> positions) {
    return Polyline(
      polylineId: PolylineId(positions.hashCode.toString()),
      visible: true,
      points: positions
          .map((position) => LatLng(position.latitude, position.longitude))
          .toList(),
      color: Colors.red,
      width: 5,
    );
  }

  Set<Marker> _makeMarkers() {
    if (_spots == null) {
      return {};
    }

    List<Marker> result = [];
    _spots?.forEach((spotId, spot) {
      var marker = Marker(
        markerId: MarkerId(spot.hashCode.toString()),
        position: LatLng(spot.point.latitude, spot.point.longitude),
        alpha: 0.7,
        onTap: () {
          if (_mapPointTapCallBack != null) {
            _mapPointTapCallBack!(spot.id);
          }
        },
        infoWindow: InfoWindow(
            title: spot.title,
            snippet:
                "${DateFormat('yyyy-MM-dd HH:mm').format(spot.date)}\n${spot.comment}"),
      );
      result.add(marker);
    });
    return result.toSet();
  }
}

class MapController {
  GoogleMapController? _controller;

  void subscribe(GoogleMapController controller) {
    _controller = controller;
  }

  Future<void> move(Position position) async {
    if (_controller == null) {
      return;
    }
    var zoom = await _controller!.getZoomLevel();
    _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: zoom,
    )));
  }
}
