import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Constant/Constant.dart';
import 'package:flutterpracticeversion22/Core/GlobalVaribale.dart';
import 'package:flutterpracticeversion22/Screen/LoginScreen/LoginScreen.dart';
import 'package:flutterpracticeversion22/Screen/ProfileScreen/Manager/ProfileManager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreenProvider extends ChangeNotifier {
  refresh() {
    GlobalVariable.homeProvider.notifyListeners();
  }

  var manager = ProfileManager();

  Future<void> loadUserProfile() async {
    manager.user = FirebaseAuth.instance.currentUser;

    if (manager.user != null) {
      if (manager.user!.providerData
          .any((info) => info.providerId == 'google.com')) {
        manager.displayName = manager.user!.displayName;
        manager.email = manager.user!.email;
        manager.photoURL = manager.user!.photoURL;
        refresh();
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      manager.displayName = prefs.getString('userName') ?? 'Guest User';
      manager.email = prefs.getString('userEmail') ?? 'No email available';
      refresh();
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    if (manager.user != null &&
        manager.user!.providerData
            .any((info) => info.providerId == 'google.com')) {
      await GoogleSignIn().signOut();
    }
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      Constant.getRootContext(),
      MaterialPageRoute(builder: (context) => LoginView2()),
    );
  }
}
