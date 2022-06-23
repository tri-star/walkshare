import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/lib/router/app_router.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/repositories/map_info_repository.dart';
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
        Provider<ImageLoader>(
          create: (_) => ImageLoader(),
        ),
        ChangeNotifierProvider<RouterState>.value(value: routerState),
      ],
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          var authService = Provider.of<AuthService>(context);
          if (snapshot.hasData) {
            // return const WalkShareApp();
            authService.setUser(snapshot.data);
          } else {
            authService.setUser(null);
          }
          return Consumer<RouterState>(
              builder: (context, value, child) => MaterialApp.router(
                    title: 'WalkShare',
                    theme: LightThemeBuilder().build(),
                    routerDelegate: router.routerDelegate,
                    routeInformationParser: router.routeInformationParser,
                  ));
        },
      ),
    );
  }
}
