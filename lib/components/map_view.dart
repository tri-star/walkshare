import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/domain/stroll_route.dart';

class MapView extends StatelessWidget {
  final Position _initialPosition;
  final MapController _controller;
  final StrollRoute _strollRoute;
  final MapInfo? _mapInfo;

  const MapView(MapController controller, Position initialPosition,
      StrollRoute strollRoute, MapInfo? mapInfo,
      {Key? key})
      : _controller = controller,
        _initialPosition = initialPosition,
        _strollRoute = strollRoute,
        _mapInfo = mapInfo,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(_initialPosition.latitude, _initialPosition.longitude),
        zoom: 15,
      ),
      myLocationEnabled: true, // 後でON/OFFできる必要がある
      onCameraMove: _onCameraMove,
      onLongPress: (LatLng newPos) {
        FirebaseAnalytics.instance.logEvent(
          name: "map_long_pressed",
          parameters: {},
        );
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: const [
                        Text('タイトル'),
                        Expanded(child: TextField()),
                      ],
                    ),
                    Row(
                      children: const [
                        Text('コメント'),
                        Expanded(child: TextField()),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(onPressed: null, child: Text('OK')),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('CANCEL')),
                      ],
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom)),
                  ],
                ),
              );
            });
      },
      polylines: [_makePolyLines(_strollRoute.routePoints)].toSet(),
      markers: _makeMarkers(_mapInfo?.points).toSet(),
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

  Set<Marker> _makeMarkers(List<MapPoint>? points) {
    if (points == null) {
      return {};
    }
    return points
        .map((point) => Marker(
              markerId: MarkerId(point.hashCode.toString()),
              position: LatLng(point.point.latitude, point.point.longitude),
              infoWindow: InfoWindow(
                  title: point.title,
                  snippet: "${point.date.toIso8601String()}\n${point.comment}"),
            ))
        .toSet();
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
