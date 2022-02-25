import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:strollog/domain/position.dart';

class MapView extends StatelessWidget {
  final Position _position;

  const MapView(Position position, {Key? key})
      : _position = position,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        initialCameraPosition: CameraPosition(
      target: LatLng(_position.latitude, _position.longitude),
      zoom: 15,
    ));
  }
}
