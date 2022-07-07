import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/pages/app_page.dart';
import 'package:strollog/pages/map/map_page.dart';
import 'package:strollog/pages/map/point_edit_form_store.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/photo_repository.dart';
import 'package:strollog/services/auth_service.dart';

class WalkShareApp extends AppPage {
  @override
  Widget buildPage(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    if (!authService.isSignedIn()) {
      return const CircularProgressIndicator();
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PointEditFormStore>(
            create: (_context) => PointEditFormStore(
                Provider.of<MapInfoRepository>(_context, listen: false),
                Provider.of<PhotoRepository>(_context, listen: false),
                Provider.of<AuthService>(_context, listen: false))),
      ],
      child: const MapPage(),
    );
  }
}
