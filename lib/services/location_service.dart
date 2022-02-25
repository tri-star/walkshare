import 'package:geolocator/geolocator.dart';
import 'package:strollog/domain/location_permission_result.dart';
import 'package:strollog/domain/position.dart' as AppPosition;

class LocationService {
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermissionResult> checkPermission() async {
    LocationPermission geoLocatorPermission =
        await Geolocator.checkPermission();
    return toLocationPermissionResult(geoLocatorPermission);
  }

  Future<LocationPermissionResult> requestPermission() async {
    LocationPermission geoLocatorPermission =
        await Geolocator.requestPermission();
    return toLocationPermissionResult(geoLocatorPermission);
  }

  Future<AppPosition.Position> getCurrentPosition() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return _toAppPosition(position);
  }

  LocationPermissionResult toLocationPermissionResult(
      LocationPermission geoLocatorPermission) {
    switch (geoLocatorPermission) {
      case LocationPermission.always:
        return LocationPermissionResult.always;
      case LocationPermission.whileInUse:
        return LocationPermissionResult.whileInUse;
      case LocationPermission.denied:
        return LocationPermissionResult.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionResult.deniedForever;
      case LocationPermission.unableToDetermine:
        return LocationPermissionResult.unknown;
    }
  }

  AppPosition.Position _toAppPosition(Position position) {
    return AppPosition.Position(position.latitude, position.longitude);
  }
}
