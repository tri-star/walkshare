import 'package:faker_dart/faker_dart.dart';
import 'package:strollog/domain/face_photo.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/lib/test/faker_builder.dart';

class NameFaker {
  static PrepareFunction<Name> prepare({
    String? name,
    String? pronounce,
    FacePhoto? facePhoto,
    String? place,
    String? memo,
    String? id,
  }) {
    return () {
      var faker = Faker.instance;

      name ??= faker.name.fullName();
      pronounce ??= faker.name.fullName();
      memo ??= faker.lorem.text();
      place ??= faker.address.city();
      return Name(
          name: name!,
          pronounce: pronounce!,
          facePhoto: facePhoto,
          memo: memo!,
          place: place!,
          id: id);
    };
  }
}
