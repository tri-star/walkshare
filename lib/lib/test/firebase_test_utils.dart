import 'package:faker_dart/faker_dart.dart';
import 'package:strollog/domain/user.dart';
import 'package:ulid/ulid.dart';

class FirebaseTestUtil {
  static User createUser({String? id, String? name}) {
    var faker = Faker.instance;

    id ??= Ulid().toString();
    name ??= faker.locale.name.name?.join(" ") ?? '';
    return User(id, name, '');
  }
}
