import 'package:ulid/ulid.dart';

class Name {
  String id;
  String name;
  String pronounce;
  String place;
  String memo;
  DateTime created;

  Name(
      {String? id,
      required this.name,
      required this.pronounce,
      this.place = '',
      this.memo = '',
      DateTime? created})
      : id = id ?? Ulid().toString(),
        created = created ?? DateTime.now();
}
