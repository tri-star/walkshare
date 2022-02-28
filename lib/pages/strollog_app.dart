import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/map_view.dart';
import 'package:strollog/domain/location_permission_result.dart';
import 'package:strollog/pages/map_page_store.dart';
import 'package:strollog/repositories/route_repository.dart';
import 'package:strollog/services/auth_service.dart';
import 'package:strollog/services/location_service.dart';

class StrollogApp extends StatelessWidget {
  const StrollogApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapPageStore>(
          create: (_context) {
            return MapPageStore(
                Provider.of<AuthService>(_context, listen: false),
                Provider.of<LocationService>(_context, listen: false),
                Provider.of<RouteRepository>(_context, listen: false));
          },
        ),
        Provider<Completer<GoogleMapController>>(
          create: (_context) => Completer(),
        ),
      ],
      child: const MapPage(),
    );
  }
}

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
        title: const Text('Map sample'),
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
