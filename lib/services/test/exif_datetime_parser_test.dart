import 'package:intl/intl.dart';
import 'package:strollog/services/exif_datetime_parser.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  late ExifDateTimeParser parser;

  setUp(() {
    parser = ExifDateTimeParser();
  });

  group('有効な画像', () {
    test('EXIF情報を含んだ画像から日付情報をロードできること', () async {
      String path = p.joinAll(
          ['lib', 'services', 'test', 'fixtures', 'with_exif_date.jpg']);
      var date = await parser.parseFromPath(path);

      expect(DateFormat('yyyy-MM-dd HH:mm:ss').format(date!),
          '2022-03-19 15:54:40');
    });

    test('EXIF情報を含まない画像の場合はnullが帰ること', () async {
      String path = p
          .joinAll(['lib', 'services', 'test', 'fixtures', 'without_exif.png']);
      var date = await parser.parseFromPath(path);

      expect(date, null);
    });
  });

  group('存在しない画像', () {
    test('存在しない画像の場合はnullが帰ること', () async {
      String path =
          p.joinAll(['lib', 'services', 'test', 'fixtures', 'unknown.png']);
      var date = await parser.parseFromPath(path);

      expect(date, null);
    });
  });
}
