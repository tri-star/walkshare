import 'package:firebase_auth/firebase_auth.dart';
import 'package:strollog/domain/user.dart' as AppUser;

class AuthService {
  User? _user;

  void setUser(User? user) {
    _user = user;
  }

  bool isSignedIn() {
    return _user != null;
  }

  AppUser.User getUser() {
    return AppUser.User(
        _user!.uid, _user!.displayName ?? '', _user!.photoURL ?? '');
  }
}
