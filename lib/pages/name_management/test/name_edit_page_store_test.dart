import 'package:strollog/domain/user.dart';
import 'package:strollog/lib/test/firebase_test_utils.dart';
import 'package:strollog/services/auth_service.dart';
import 'package:test/test.dart';

void main() {
  late AuthService authService;
  late User testUser;

  setUp(() {
    authService = AuthService();
    // store = NameEditPageStore(
    //     MapInfoRepository(FakeFirebaseFirestore()),
    //     PhotoRepository(FakeFirebaseFirestore(), MockFirebaseStorage()),
    //     authService,
    //     ImagePickerStub());

    testUser = FirebaseTestUtil.createUser();
    authService.setUser(testUser);
  });

  // group('バリデーション', () {
  //   test('タイトルが未入力__NG', () {
  //     var result = store.validateTitle('');
  //     expect(result, 'タイトルを入力してください');
  //   });
  //   test('タイトルが入力済__OK', () {
  //     var result = store.validateTitle('title');
  //     expect(result, null);
  //   });
  // });
}
