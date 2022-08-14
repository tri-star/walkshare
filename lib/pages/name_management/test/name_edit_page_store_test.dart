import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/domain/user.dart';
import 'package:strollog/lib/test/faker_builder.dart';
import 'package:strollog/lib/test/fakers/map_info_faker.dart';
import 'package:strollog/lib/test/fakers/name_faker.dart';
import 'package:strollog/lib/test/firebase_test_utils.dart';
import 'package:strollog/lib/test/image_cropper_stub.dart';
import 'package:strollog/lib/test/image_picker_stub.dart';
import 'package:strollog/pages/name_management/name_edit_page_store.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/name_repository.dart';
import 'package:strollog/services/auth_service.dart';
import 'package:strollog/services/image_loader.dart';
import 'package:test/test.dart';

void main() {
  late AuthService authService;
  late NameEditPageStore store;
  late User testUser;
  late MapInfoRepository mapInfoRepository;
  late NameRepository nameRepository;

  setUp(() {
    authService = AuthService();
    var fakeFirestore = FakeFirebaseFirestore();
    var fakeFirebaseStorage = MockFirebaseStorage();
    mapInfoRepository = MapInfoRepository(fakeFirestore);
    nameRepository = NameRepository(fakeFirestore, fakeFirebaseStorage);

    store = NameEditPageStore(
        nameRepository,
        mapInfoRepository,
        ImagePickerStub(),
        ImageCropperStub(),
        ImageLoaderFace(fakeFirebaseStorage));

    testUser = FirebaseTestUtil.createUser();
    authService.setUser(testUser);
  });

  group('バリデーション', () {
    test('名前が未入力__NG', () {
      var result = store.validateName('');
      expect(result, '名前を入力してください');
    });
    test('名前が入力済__OK', () {
      var result = store.validateName('title');
      expect(result, null);
    });
    test('読みが未入力__NG', () {
      var result = store.validatePronounce('');
      expect(result, '読みを入力してください');
    });
    test('読みが入力済__OK', () {
      var result = store.validatePronounce('よみ');
      expect(result, null);
    });
  });

  group('保存処理', () {
    group('事前に写真登録なしの場合', () {
      test('画像なしで保存__保存できること', () async {
        // 顔写真なしの名前データを作成し、保存しておく
        var mapInfo = FakerBuilder<MapInfo>().create(MapInfoFaker.prepare());
        var name = FakerBuilder<Name>().create(NameFaker.prepare());

        await mapInfoRepository.save(mapInfo);
        await nameRepository.save(testUser, mapInfo.id!, name);

        await store.initialize(mapInfo.id!, name.id);
        // 名前等を変更して保存を実行
        var expectedName = '名前変更';
        store.name.name = expectedName;
        store.setInteracted(true);

        await store.save();

        var result = await nameRepository.fetchNameById(mapInfo.id!, name.id);
        expect(result!.name, expectedName);
      });
      test('画像を付けて保存__その写真が保存されること', () async {});
    });

    group('事前に写真登録ありの場合', () {
      test('画像なしで保存__元の画像が残ること', () async {});
      test('画像を付けて保存__新しい写真が保存されること', () async {});
    });

    test('各項目の変更が反映されていること', () {});
  });
}
