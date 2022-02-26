import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:strollog/domain/position.dart';

class MapView extends StatelessWidget {
  final Position _position;
  GoogleMapController? _googleMapController;
  MapController _controller;

  MapView(MapController controller, Position position, {Key? key})
      : _controller = controller,
        _position = position,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_googleMapController != null) {}

    return GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(_position.latitude, _position.longitude),
          zoom: 15,
        ));
  }

  _onMapCreated(GoogleMapController googleMapController) {
    _controller.subscribe(googleMapController);
  }
}

class MapController {
  GoogleMapController? _controller;

  void subscribe(GoogleMapController controller) {
    _controller = controller;
  }

  void move(Position position) {
    _controller?.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15,
    )));
  }
}
