import 'package:ulid/ulid.dart';
import 'package:path/path.dart' as p;

class Photo {
  String key;

  String extension;

  DateTime? date;

  String? uid;

  Photo(
      {this.key = '', this.extension = '', this.date = null, this.uid = null}) {
    if (key == '') {
      key = Ulid().toString();
    }
  }

  Photo.fromPath(String path, this.uid, {String? key, DateTime? date})
      : key = key ?? Ulid().toString(),
        date = date ?? DateTime.now(),
        extension = p.extension(path);

  Photo.fromJson(Map<String, dynamic> json)
      : key = json['key'] ?? '',
        date = json['date']?.toDate(),
        uid = json['uid'],
        extension = json['extension'] ?? '';

  String getFileName() {
    return '${key}${extension}';
  }

  Map<String, Object?> toJson() {
    return {
      'key': key,
      'extension': extension,
      'date': date,
      'uid': uid,
    };
  }
}
