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

enum DraftPhotoType { draft, saved }

/// 新規登録/編集保存前状態の写真
class DraftPhoto {
  DraftPhotoType type;
  Name? name;

  /// 写真ピッカーで選択した写真
  XFile? file;

  /// 保存済の写真
  Photo? savedPhoto;
  Future<String> Function()? loadCacheCallback;
  String? cachePath;

  DraftPhoto.draft(this.file, {this.name}) : type = DraftPhotoType.draft;

  DraftPhoto.saved(Photo photo, {required this.loadCacheCallback})
      : savedPhoto = photo,
        cachePath = null,
        type = DraftPhotoType.saved {
    name = savedPhoto?.name;
  }

  String keyString() {
    if (isDraft()) {
      return 'DRAFT_${file!.path}';
    } else {
      return 'SAVED_${savedPhoto!.key}';
    }
  }

  bool isDraft() {
    return type == DraftPhotoType.draft;
  }

  /// 写真ピッカー / 保存済のどちらの場合も参照可能な画像のパスを返す
  Future<String> get getImagePath async {
    if (isDraft()) {
      return file!.path;
    } else {
      if (cachePath == null) {
        if (loadCacheCallback == null) {
          throw Exception('loadCacheCallback is null');
        }
        cachePath = await loadCacheCallback!();
      }
      return cachePath!;
    }
  }
}
