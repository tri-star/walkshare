import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/map_view.dart';
import 'package:strollog/domain/location_permission_result.dart';
import 'package:strollog/pages/map/map_page_store.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapPageStore? _state;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strollog'),
      ),
      body: _createMapView(),
    );
  }

  Widget _createMapView() {
    if (_state == null) {
      _state = Provider.of<MapPageStore>(context);
      _state!.setMapController(_mapController);
      _state!.init().then((_) {
        if (!_state!.locationRequested) {
          _state!.requestLocationPermission().then((permission) {
            if (permission == LocationPermissionResult.deniedForever) {
              return const Center(child: Text("位置情報の使用が拒否されています。"));
            }
            _state!.updateLocation();
          });
        }
      });
    }

    if (_state!.position == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(children: [
      Expanded(
          child:
              MapView(_mapController, _state!.position!, _state!.strollRoute)),
      Text(_state!.strollRoute.routePoints.length.toString(),
          textAlign: TextAlign.right),
    ]);
  }
}
