import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:strollog/domain/location_permission_result.dart';
import 'package:strollog/domain/position.dart' as AppPosition;

typedef LocationUpdateCallback = Function(AppPosition.Position newPosition);

class LocationService {
  StreamSubscription? _subscription;

  LocationService() {
    FirebaseAnalytics.instance.logEvent(
      name: "init_location_service",
      parameters: {},
    );
  }

  void listen(LocationUpdateCallback callback) {
    if (_subscription != null) {
      // await _subscription!.cancel();
      FirebaseAnalytics.instance.logEvent(
        name: "listen_location_error",
        parameters: {
          "message": "二重に呼び出されました",
        },
      );
      return;
    }

    late LocationSettings setting;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      setting = AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          activityType: ActivityType.fitness,
          pauseLocationUpdatesAutomatically: false);
    } else {
      setting = const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
        timeLimit: Duration(seconds: 5),
      );
    }

    _subscription = Geolocator.getPositionStream(locationSettings: setting)
        .listen((position) {
      callback(AppPosition.Position(position.latitude, position.longitude));
    });
    _subscription?.onError((e) {
      FirebaseAnalytics.instance.logEvent(
        name: "listen_location_error",
        parameters: {
          "message": e.toString(),
        },
      );
      _subscription = Geolocator.getPositionStream(locationSettings: setting)
          .listen((position) {
        callback(AppPosition.Position(position.latitude, position.longitude));
      });
    });
  }

  Future<void> stopListen() async {
    if (_subscription == null) {
      return;
    }
    await _subscription!.cancel();
    _subscription = null;
  }

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
