import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/domain/stroll_route.dart';

class MapView extends StatelessWidget {
  final Position _initialPosition;
  final MapController _controller;
  final StrollRoute _strollRoute;

  const MapView(MapController controller, Position initialPosition,
      StrollRoute strollRoute,
      {Key? key})
      : _controller = controller,
        _initialPosition = initialPosition,
        _strollRoute = strollRoute,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(_initialPosition.latitude, _initialPosition.longitude),
        zoom: 15,
      ),
      onCameraMove: _onCameraMove,
      polylines: [_makePolyLines(_strollRoute.routePoints)].toSet(),
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
