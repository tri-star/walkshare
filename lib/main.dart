import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:strollog/lib/router/app_router.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/pages/app_store.dart';
import 'package:strollog/pages/map/map_page_store.dart';
import 'package:strollog/pages/map/point_edit_form_store.dart';
import 'package:strollog/pages/map/spot_create_page_store.dart';
import 'package:strollog/pages/name_management/name_add_page_store.dart';
import 'package:strollog/pages/name_management/name_detail_page_store.dart';
import 'package:strollog/pages/name_management/name_list_page_store.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/name_repository.dart';
import 'package:strollog/repositories/photo_repository.dart';
import 'package:strollog/repositories/route_repository.dart';
import 'package:strollog/router/app_location.dart';
import 'package:strollog/router/route_definition.dart';
import 'package:strollog/services/auth_service.dart';
import 'package:strollog/services/image_loader.dart';
import 'package:strollog/services/location_service.dart';
import 'package:strollog/theme/light_theme_builder.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (!kIsWeb) {
      await Firebase.initializeApp();
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      throw UnimplementedError("Web版は未対応です");
    }

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    runApp(Application());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class Application extends StatefulWidget {
  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  late AppRouter router;
  late RouterState routerState;

  @override
  void initState() {
    super.initState();
    routerState = RouterState(AppLocationHome());
    router =
        AppRouter(routeDefinition: RouteDefinition(), routerState: routerState);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocationService>(
          create: (_) => LocationService(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<RouteRepository>(
          create: (_) => RouteRepository(),
        ),
        Provider<MapInfoRepository>(
          create: (_) => MapInfoRepository(),
        ),
        Provider<PhotoRepository>(
          create: (_) => PhotoRepository(),
        ),
        Provider<NameRepository>(
          create: (_) => NameRepository(),
        ),
        Provider<ImageLoader>(
          create: (_) => ImageLoader(PhotoType.photo),
        ),
        ChangeNotifierProvider<RouterState>.value(value: routerState),
        ChangeNotifierProvider<AppStore>(
            create: (_context) => AppStore(
                Provider.of<MapInfoRepository>(_context, listen: false))),
        ChangeNotifierProvider<SpotCreatePageStore>(
            create: (_context) => SpotCreatePageStore(
                  Provider.of<MapInfoRepository>(_context, listen: false),
                  Provider.of<PhotoRepository>(_context, listen: false),
                  Provider.of<AuthService>(_context, listen: false),
                )),
        ChangeNotifierProvider<PointEditFormStore>(
            create: (_context) => PointEditFormStore(
                Provider.of<MapInfoRepository>(_context, listen: false),
                Provider.of<PhotoRepository>(_context, listen: false),
                Provider.of<AuthService>(_context, listen: false))),
        ChangeNotifierProvider<NameAddPageStore>(
            create: (_context) => NameAddPageStore(
                Provider.of<NameRepository>(_context, listen: false),
                Provider.of<MapInfoRepository>(_context, listen: false))),
        ChangeNotifierProvider<NameListPageStore>(
            create: (_context) => NameListPageStore(
                Provider.of<NameRepository>(_context, listen: false),
                Provider.of<MapInfoRepository>(_context, listen: false))),
        ChangeNotifierProvider<NameDetailPageStore>(
            create: (_context) => NameDetailPageStore(
                Provider.of<NameRepository>(_context, listen: false),
                Provider.of<MapInfoRepository>(_context, listen: false))),
        ChangeNotifierProvider<MapPageStore>(
          create: (_context) {
            return MapPageStore(
                Provider.of<AuthService>(_context, listen: false),
                Provider.of<LocationService>(_context, listen: false),
                Provider.of<RouteRepository>(_context, listen: false),
                Provider.of<MapInfoRepository>(_context, listen: false));
          },
        ),
        Provider<Completer<GoogleMapController>>(
          create: (_context) => Completer(),
        ),
      ],
      child: _handleSignin(context, () {
        return _handleinitializeMapInfo(context, () {
          return Consumer<RouterState>(
              builder: (context, value, child) => MaterialApp.router(
                    title: 'WalkShare',
                    theme: LightThemeBuilder().build(),
                    routerDelegate: router.routerDelegate,
                    routeInformationParser: router.routeInformationParser,
                  ));
        });
      }),
    );
  }

  Widget _handleSignin(BuildContext context, Widget Function() callback) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        var authService = Provider.of<AuthService>(context);
        if (snapshot.hasData) {
          // return const WalkShareApp();
          authService.setUser(snapshot.data);
        } else {
          authService.setUser(null);
        }
        return callback.call();
      },
    );
  }

  Widget _handleinitializeMapInfo(
      BuildContext context, Widget Function() callback) {
    return Consumer<AppStore>(
      builder: (context, appStore, child) {
        if (appStore.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (appStore.currentMap == null) {
          appStore.loadMapInfo();
          return const Center(child: CircularProgressIndicator());
        }
        return callback.call();
      },
    );
  }
}
