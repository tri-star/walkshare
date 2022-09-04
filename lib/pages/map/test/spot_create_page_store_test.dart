import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/domain/user.dart';
import 'package:strollog/lib/test/faker_builder.dart';
import 'package:strollog/fakers/map_info_faker.dart';
import 'package:strollog/fakers/position_faker.dart';
import 'package:strollog/lib/test/firebase_test_utils.dart';
import 'package:strollog/lib/test/image_picker_stub.dart';
import 'package:strollog/pages/map/spot_create_page_store.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/name_repository.dart';
import 'package:strollog/repositories/photo_repository.dart';
import 'package:strollog/services/auth_service.dart';
import 'package:test/test.dart';

void main() {
  late AuthService authService;
  late SpotCreatePageStore store;
  late User testUser;

  setUp(() {
    authService = AuthService();
    var fakeFireStore = FakeFirebaseFirestore();
    var fakeFirebaseStorage = MockFirebaseStorage();

    store = SpotCreatePageStore(
        MapInfoRepository(fakeFireStore),
        PhotoRepository(fakeFireStore, fakeFirebaseStorage),
        NameRepository(fakeFireStore, fakeFirebaseStorage),
        authService,
        ImagePickerStub());

    testUser = FirebaseTestUtil.createUser();
    authService.setUser(testUser);
  });

  group('バリデーション', () {
    test('タイトルが未入力__NG', () {
      var result = store.validateTitle('');
      expect(result, 'タイトルを入力してください');
    });
    test('タイトルが入力済__OK', () {
      var result = store.validateTitle('title');
      expect(result, null);
    });
  });

  group('保存処理', () {
    group('保存不可能', () {
      test('フォームに何も変更していない状態で保存実行', () {
        var result = store.canSave();
        expect(result, false);
      });

      test('保存処理中に再度保存を実行', () {
        var mapInfo = FakerBuilder<MapInfo>().create(MapInfoFaker.prepare());
        var position = FakerBuilder<Position>().create(PositionFaker.prepare());
        store.initialize(mapInfo, position);

        store.setInteracted(true);

        store.save();
        var result = store.canSave();
        expect(result, false);
      });
    });

    group('保存可能', () {
      test('フォームに何か変更を加えた後で保存実行', () async {
        var mapInfo = FakerBuilder<MapInfo>().create(MapInfoFaker.prepare());
        var position = FakerBuilder<Position>().create(PositionFaker.prepare());
        store.initialize(mapInfo, position);

        store.setInteracted(true);

        var result = await store.save();
        expect(result.id, isNotEmpty);
      });
    });
  });
}
