import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/user.dart';
import 'package:strollog/fakers/spot_faker.dart';
import 'package:strollog/lib/test/faker_builder.dart';
import 'package:strollog/fakers/map_info_faker.dart';
import 'package:strollog/lib/test/firebase_test_utils.dart';
import 'package:strollog/lib/test/image_picker_stub.dart';
import 'package:strollog/pages/map/spot_edit_page_store.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/name_repository.dart';
import 'package:strollog/repositories/photo_repository.dart';
import 'package:strollog/services/auth_service.dart';
import 'package:strollog/services/image_loader.dart';
import 'package:test/test.dart';

void main() {
  late AuthService authService;
  late SpotEditPageStore store;
  late MapInfoRepository mapInfoRepository;
  late User testUser;

  late FakeFirebaseFirestore fakeFireStore;

  setUp(() {
    authService = AuthService();
    fakeFireStore = FakeFirebaseFirestore();
    var fakeFirebaseStorage = MockFirebaseStorage();
    var imagePickerStub = ImagePickerStub();

    mapInfoRepository = MapInfoRepository(fakeFireStore);
    store = SpotEditPageStore(
        mapInfoRepository,
        PhotoRepository(fakeFireStore, fakeFirebaseStorage),
        NameRepository(fakeFireStore, fakeFirebaseStorage),
        authService,
        imagePickerStub,
        ImageLoaderPhoto(fakeFirebaseStorage,
            FirebaseStorageDownloaderStub(fakeFirebaseStorage)));

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
    group('写真なしデータの保存', () {
      test('更新時も写真なしで保存__保存できること', () async {
        var mapInfo = FakerBuilder<MapInfo>().create(MapInfoFaker.prepare());
        var spot = FakerBuilder<Spot>().create(SpotFaker.prepare());
        await mapInfoRepository.save(mapInfo);
        await mapInfoRepository.addSpot(mapInfo, null, spot);
        await store.init(mapInfo, spot.id);

        var expectedTitle = '変更テスト';
        store.title = expectedTitle;
        store.setInteracted(true);
        await store.save();

        var updatedSpot = await mapInfoRepository.fetchSpot(mapInfo, spot.id);
        expect(updatedSpot.title, expectedTitle);
      });
    });
  });
}
