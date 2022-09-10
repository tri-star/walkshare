import 'dart:io';

import 'package:exif/exif.dart';

class ExifDateTimeParser {
  Future<DateTime?> parseFromPath(String path) async {
    if (!await File(path).exists()) {
      return null;
    }

    final fileBytes = File(path).readAsBytesSync();
    final data = await readExifFromBytes(fileBytes);
    if (data.isEmpty) {
      return null;
    }

    final dateTimeString = data['EXIF DateTimeOriginal']?.toString();
    if (dateTimeString == null) {
      return null;
    }

    // exifライブラリから返される日付情報は年月日も":""で区切られているように見えるため、
    // 独自の方法でパースする
    var regExp = RegExp(
        r'^([0-9]+):([0-9]{2}):([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2})$');
    var match = regExp.firstMatch(dateTimeString);

    if (match != null) {
      return _buildDateTimeFromMatch(match);
    }

    return DateTime.tryParse(dateTimeString);
  }

  DateTime? _buildDateTimeFromMatch(Match match) {
    var y = int.tryParse(match.group(1) ?? '') ?? 0;
    var m = int.tryParse(match.group(2) ?? '') ?? 0;
    var d = int.tryParse(match.group(3) ?? '') ?? 0;
    var h = int.tryParse(match.group(4) ?? '') ?? 0;
    var min = int.tryParse(match.group(5) ?? '') ?? 0;
    var s = int.tryParse(match.group(6) ?? '') ?? 0;

    return DateTime(y, m, d, h, min, s);
  }
}
