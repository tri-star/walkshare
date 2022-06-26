import 'package:ulid/ulid.dart';
import 'package:path/path.dart' as p;

class FacePhoto {
  String key;

  String extension;

  DateTime? date;

  FacePhoto({this.key = '', this.extension = '', this.date}) {
    if (key == '') {
      key = Ulid().toString();
    }
  }

  FacePhoto.fromPath(String path, {String? key, DateTime? date})
      : key = key ?? Ulid().toString(),
        date = date ?? DateTime.now(),
        extension = p.extension(path);

  FacePhoto.fromJson(Map<String, dynamic> json)
      : key = json['key'] ?? '',
        date = json['date']?.toDate(),
        extension = json['extension'] ?? '';

  String getFileName() {
    return '${key}${extension}';
  }

  Map<String, Object?> toJson() {
    return {
      'key': key,
      'extension': extension,
      'date': date,
    };
  }
}
