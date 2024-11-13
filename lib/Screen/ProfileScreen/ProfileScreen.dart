import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterpracticeversion22/Components/customdialougue.dart';
import 'package:flutterpracticeversion22/Screen/LoginScreen/LoginScreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterpracticeversion22/Screen/SigninScreen/SigninScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  User? user;
  String? displayName;
  String? email;
  String? photoURL;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (user!.providerData.any((info) => info.providerId == 'google.com')) {
        setState(() {
          displayName = user!.displayName;
          email = user!.email;
          photoURL = user!.photoURL;
        });
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        displayName = prefs.getString('userName') ?? 'Guest User';
        email = prefs.getString('userEmail') ?? 'No email available';
      });
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    if (user != null &&
        user!.providerData.any((info) => info.providerId == 'google.com')) {
      await GoogleSignIn().signOut();
    }
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginView2()),
    );
  }

  Widget _buildProfileOption(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: () {
        print('$label tapped');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage: photoURL != null
                    ? NetworkImage(photoURL!)
                    : AssetImage('assets/images/profile1.png') as ImageProvider,
              ),
              const SizedBox(height: 10),
              Text(
                displayName ?? 'Guest User',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                email ?? 'No email available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    print('Edit Profile clicked');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue),
                    foregroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Edit Profile'),
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileOption(Icons.insert_drive_file, 'Doc Management'),
              _buildProfileOption(Icons.help, 'Help'),
              _buildProfileOption(Icons.description, 'Terms of Services'),
              _buildProfileOption(Icons.privacy_tip, 'Privacy Policy'),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  DialogueBox.showLogoutConfirmation(context, logout);
                  print('Logout tapped');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
