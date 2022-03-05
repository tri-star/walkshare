import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthPage extends StatefulWidget {
  AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
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
                    children: const [
                      Text('test')
                      // Container(
                      //   margin: EdgeInsets.only(bottom: 20),
                      //   child: Text('Strollog', style: TextStyle(fontSize: 40)),
                      // ),
                      // Center(
                      //   child: Expanded(
                      //       child: AnimatedSwitcher(
                      //           duration: const Duration(milliseconds: 300),
                      //           child: _isLoading
                      //               ? Container(
                      //                   color: Colors.grey[200], height: 50)
                      //               : SizedBox(
                      //                   height: 50,
                      //                   child: SignInButton(
                      //                     Buttons.Google,
                      //                     onPressed: _signInWithGoogle,
                      //                   ),
                      //                 ))),

                      //   // _errorMessage != ''
                      //   //     ? SizedBox(height: 50, child: Text(_errorMessage))
                      //   //     : const SizedBox(height: 50, child: Text("")),
                      // ),
                      // SizedBox(
                      //   height: 80,
                      //   child: null,
                      // ),
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
      setError(e.message!);
    } on PlatformException catch (e) {
      setError(e.message!);
    } finally {
      setLoading(false);
    }
  }
}
