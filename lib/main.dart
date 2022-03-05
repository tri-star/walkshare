import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/pages/auth_page.dart';
import 'package:strollog/pages/strollog_app.dart';
import 'package:strollog/repositories/route_repository.dart';
import 'package:strollog/services/auth_service.dart';
import 'package:strollog/services/location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await Firebase.initializeApp();
  } else {
    throw UnimplementedError("Web版は未対応です");
  }

  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strollog',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MultiProvider(
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
        ],
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            return const Text('Simple');
            // if (snapshot.hasData) {
            //   return const StrollogApp();
            // } else {
            //   return AuthPage();
            // }
          },
        ),
      ),
    );
  }
}
