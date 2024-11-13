import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterpracticeversion22/Screen/HomeScreen/HomeScreen.dart';
import 'package:flutterpracticeversion22/Screen/SigninScreen/SigninScreen.dart';
import 'package:flutterpracticeversion22/Screen/SignupScreen/SignupScreen.dart';

class LoginView2 extends StatefulWidget {
  const LoginView2({super.key});

  @override
  State<LoginView2> createState() => _LoginView2State();
}

class _LoginView2State extends State<LoginView2> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _showButtons = true;
      });
    });
  }

  Future<void> loginWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (error) {
      print("Google sign-in failed: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign in with Google")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void login() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _showButtons ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: Image.asset('assets/images/profile1.png'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Get Started!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: _showButtons ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        icon: Image.asset('assets/images/google12.png',
                            height: 20),
                        label: Text('Continue with Google'),
                        onPressed: loginWithGoogle,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                                color: Color.fromARGB(255, 179, 219, 252)),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider()),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Or"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text("Sign In"),
                        ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don’t have an account?"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
