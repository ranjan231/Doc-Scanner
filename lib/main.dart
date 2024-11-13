import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Constant/Constant.dart';
import 'package:flutterpracticeversion22/Screen/HomeScreen/HomeScreen.dart';
import 'package:flutterpracticeversion22/Screen/LoginScreen/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterpracticeversion22/fireBase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Developed by Ranjan',
      navigatorKey: Constant.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Initializer(),
    );
  }
}

class Initializer extends StatefulWidget {
  @override
  _InitializerState createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> {
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return isLoggedIn ? HomeScreen() : LoginView2();
  }
}
