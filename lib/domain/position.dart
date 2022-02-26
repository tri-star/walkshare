import 'package:flutter/widgets.dart';

class Position {
  double latitude;
  double longitude;

  Position(this.latitude, this.longitude);

  @override
  String toString() {
    return '$latitude, $longitude';
  }

  @override
  int get hashCode => hashValues(latitude, longitude);
}
