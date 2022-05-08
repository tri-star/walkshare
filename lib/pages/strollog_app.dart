import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:strollog/pages/map/map_page.dart';
import 'package:strollog/pages/map/map_page_store.dart';
import 'package:strollog/pages/map/point_add_form_store.dart';
import 'package:strollog/pages/map/point_edit_form_store.dart';
import 'package:strollog/repositories/map_info_repository.dart';
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
                Provider.of<RouteRepository>(_context, listen: false),
                Provider.of<MapInfoRepository>(_context, listen: false));
          },
        ),
        ChangeNotifierProvider<PointAddFormStore>(
            create: (_context) => PointAddFormStore(
                  Provider.of<MapInfoRepository>(_context, listen: false),
                  Provider.of<AuthService>(_context, listen: false),
                )),
        ChangeNotifierProvider<PointEditFormStore>(
            create: (_context) => PointEditFormStore(
                Provider.of<MapInfoRepository>(_context, listen: false))),
        Provider<Completer<GoogleMapController>>(
          create: (_context) => Completer(),
        ),
      ],
      child: const MapPage(),
    );
  }
}
