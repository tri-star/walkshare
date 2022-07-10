import 'package:image_picker/image_picker.dart';
import 'package:strollog/domain/name.dart';
import 'package:ulid/ulid.dart';
import 'package:path/path.dart' as p;

class Photo {
  String key;

  String extension;

  DateTime? date;

  String? uid;

  Name? name;

  Photo({this.key = '', this.extension = '', this.date, this.uid, this.name}) {
    if (key == '') {
      key = Ulid().toString();
    }
  }

  Photo.fromPath(String path, this.uid,
      {String? key, DateTime? date, this.name})
      : key = key ?? Ulid().toString(),
        date = date ?? DateTime.now(),
        extension = p.extension(path);

  String getFileName() {
    return '${key}${extension}';
  }
}

/// 写真ピッカーで選択された未保存の写真
class DraftPhoto {
  Name? name;
  XFile file;

  DraftPhoto(this.file, {this.name});
}
