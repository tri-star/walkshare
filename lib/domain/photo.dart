import 'package:ulid/ulid.dart';
import 'package:path/path.dart' as p;

class Photo {
  String key;

  String extension;

  Photo({this.key = '', this.extension = ''}) {
    if (key == '') {
      key = Ulid().toString();
    }
  }

  Photo.fromPath(String path, {String? key})
      : key = key ?? Ulid().toString(),
        extension = p.extension(path);

  Photo.fromJson(Map<String, dynamic> json)
      : key = json['key'] ?? '',
        extension = json['extension'] ?? '';

  String getFileName() {
    return '${key}${extension}';
  }

  Map<String, Object?> toJson() {
    return {
      'key': key,
      'extension': extension,
    };
  }
}
