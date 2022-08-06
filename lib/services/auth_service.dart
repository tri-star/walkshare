import 'package:firebase_auth/firebase_auth.dart';
import 'package:strollog/domain/user.dart' as AppUser;

class AuthService {
  AppUser.User? _user;

  void setUser(AppUser.User? user) {
    _user = user;
  }

  void setUserFromFirebaseAuth(User? user) {
    _user = AppUser.User(
        user?.uid ?? '', user?.displayName ?? '', user?.photoURL ?? '');
  }

  bool isSignedIn() {
    return _user != null;
  }

  AppUser.User getUser() {
    return _user!;
  }
}
