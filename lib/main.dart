import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/pages/strollog_app.dart';
import 'package:strollog/services/location_service.dart';

void main() {
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
        ],
        child: const StrollogApp(),
      ),
    );
  }
}
