import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:strollog/domain/user.dart';
import 'package:strollog/lib/test/firebase_test_utils.dart';
import 'package:strollog/lib/test/image_cropper_stub.dart';
import 'package:strollog/lib/test/image_loader_stub.dart';
import 'package:strollog/lib/test/image_picker_stub.dart';
import 'package:strollog/pages/name_management/name_edit_page_store.dart';
import 'package:strollog/repositories/map_info_repository.dart';
import 'package:strollog/repositories/name_repository.dart';
import 'package:strollog/repositories/photo_repository.dart';
import 'package:strollog/services/auth_service.dart';
import 'package:test/test.dart';

void main() {
  late AuthService authService;
  late NameEditPageStore store;
  late User testUser;

  setUp(() {
    authService = AuthService();
    var fakeFirestore = FakeFirebaseFirestore();
    var fakeFirebaseStorage = MockFirebaseStorage();
    var imagePickerStub = ImagePickerStub();

    store = NameEditPageStore(
        NameRepository(fakeFirestore, fakeFirebaseStorage),
        MapInfoRepository(fakeFirestore),
        ImagePickerStub(),
        ImageCropperStub(),
        ImageLoaderFaceStub());

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
}
