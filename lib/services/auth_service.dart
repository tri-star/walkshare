import 'package:firebase_auth/firebase_auth.dart';
import 'package:strollog/domain/user.dart' as AppUser;

class AuthService {
  AppUser.User getUser() {
    var fireBaseUser = FirebaseAuth.instance.currentUser!;
    return AppUser.User(fireBaseUser.uid, fireBaseUser.displayName ?? '',
        fireBaseUser.photoURL ?? '');
  }
}
