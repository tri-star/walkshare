import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:strollog/pages/app_page.dart';

class AuthPage extends AppPage {
  @override
  Widget buildPage(BuildContext context) {
    return _AuthPage();
  }
}

class _AuthPage extends StatefulWidget {
  _AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<_AuthPage> {
  bool _isLoading = false;
  String _errorMessage = '';

  void setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void setError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                alignment: Alignment.center,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child:
                            Text('WalkShare', style: TextStyle(fontSize: 40)),
                      ),
                      Center(
                          child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isLoading
                                  ? Container(
                                      color: Colors.grey[200], height: 50)
                                  : SizedBox(
                                      height: 50,
                                      child: SignInButton(
                                        Buttons.Google,
                                        onPressed: _signInWithGoogle,
                                      ),
                                    ))),

                      // _errorMessage != ''
                      //     ? SizedBox(height: 50, child: Text(_errorMessage))
                      //     : const SizedBox(height: 50, child: Text("")),
                      const SizedBox(
                        height: 80,
                        child: null,
                      ),
                    ]))));
  }

  Future<void> _signInWithGoogle() async {
    setLoading(true);
    try {
      final user = await GoogleSignIn().signIn();
      final googleAuth = await user?.authentication;

      if (googleAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      setError(e.message!);
    } on PlatformException catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      setError(e.message!);
    } finally {
      setLoading(false);
    }
  }
}
