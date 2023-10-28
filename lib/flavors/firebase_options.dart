import 'package:firebase_core/firebase_core.dart';
import 'package:strollog/flavors/flavors.dart';

import 'package:strollog/flavors/dev/firebase_options.dart' as dev;
import 'package:strollog/flavors/prod/firebase_options.dart' as prod;

FirebaseOptions getFirebaseOptions(String flavor) {
  switch (flavor) {
    case FLAVORS.DEV:
      return dev.DefaultFirebaseOptions.currentPlatform;
    case FLAVORS.PROD:
      return prod.DefaultFirebaseOptions.currentPlatform;
    default:
      throw ArgumentError('Invalid flavor: $flavor');
  }
}
