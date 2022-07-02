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

class AppLocationNameManagement extends AppLocation {
  final String mapId;

  AppLocationNameManagement({required this.mapId}) {
    pathSegments = ['map', ':mapId', 'names'];
    parameters = {
      'mapId': mapId,
    };
  }

  @override
  String get signature => '/map/:mapId/names';

  @override
  String toPath() => UriPathBuilder.build(signature, parameters: parameters);
}

class AppLocationNameDetail extends AppLocation {
  final String mapId;
  final String nameId;

  AppLocationNameDetail({required this.mapId, required this.nameId}) {
    pathSegments = ['map', ':mapId', 'names', ':nameId'];
    parameters = {
      'mapId': mapId,
      'nameId': nameId,
    };
  }

  @override
  String get signature => '/map/:mapId/names/:nameId';

  @override
  String toPath() => UriPathBuilder.build(signature, parameters: parameters);
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
