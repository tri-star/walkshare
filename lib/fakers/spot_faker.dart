import 'package:faker_dart/faker_dart.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/domain/user.dart';
import 'package:strollog/lib/test/faker_builder.dart';
import 'package:ulid/ulid.dart';

class SpotFaker {
  static PrepareFunction<Spot> prepare({
    String? id,
    String? title,
    Position? point,
    String? comment,
    DateTime? date,
    UserNameInfo? userNameInfo,
    double? score,
    List<Photo>? photos,
    DateTime? lastVisited,
  }) {
    return () {
      var faker = Faker.instance;

      id ??= Ulid().toString();
      title ??= faker.animal.cat();
      point ??= Position(faker.address.latitude(), faker.address.longitude());
      comment ??= faker.lorem.sentence();
      date ??= DateTime.now();
      score ??= faker.datatype.float(min: 0, max: 5);
      lastVisited = date;

      return Spot(title!, point!,
          id: id,
          comment: comment!,
          newDate: date,
          score: score!,
          userNameInfo: userNameInfo,
          photos: photos,
          lastVisited: lastVisited);
    };
  }
}
