import 'package:strollog/lib/router/app_location.dart';

class AppLocationHome extends AppLocation {
  @override
  String toPath() => '/';
}

class AppLocationSignin extends AppLocation {
  @override
  String toPath() => '/signin';
}

class AppLocationMap extends AppLocation {
  @override
  String toPath() => '/map';
}

class AppLocationPhotoPreview extends AppLocation {
  final String mapId;
  final String spotId;
  final int index;

  AppLocationPhotoPreview(
      {required this.mapId, required this.spotId, required this.index}) {
    pathSegments = ['photo'];
    parameters = {'mapId': mapId, 'spotId': spotId, 'index': index.toString()};
  }

  @override
  String get signature => '/photo/:mapId/:spotId/:index';

  @override
  String toPath() {
    return UriPathBuilder.build(signature, parameters: parameters);
  }
}
