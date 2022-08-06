import 'package:faker_dart/faker_dart.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/lib/test/faker_builder.dart';

class MapInfoFaker {
  static PrepareFunction<MapInfo> prepare({
    String? name,
    String? id,
  }) {
    return () {
      var faker = Faker.instance;

      name ??= faker.locale.name.name?.join(' ') ?? '';
      return MapInfo(name!, {}, id: id);
    };
  }
}
