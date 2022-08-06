import 'package:faker_dart/faker_dart.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/lib/test/faker_builder.dart';

class PositionFaker {
  static PrepareFunction<Position> prepare() {
    return () {
      var faker = Faker.instance;
      return Position(faker.address.latitude(), faker.address.longitude());
    };
  }
}
