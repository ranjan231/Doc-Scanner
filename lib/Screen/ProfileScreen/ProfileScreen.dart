import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterpracticeversion22/Components/customdialougue.dart';
import 'package:flutterpracticeversion22/Screen/LoginScreen/LoginScreen.dart';
import 'package:flutterpracticeversion22/Screen/helpscreen/helpscreen.dart';
import 'package:flutterpracticeversion22/Screen/privacypolicyscreen/privacypolicyscreen.dart';
import 'package:flutterpracticeversion22/Screen/termsofservice/termsofservice.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
        if (label == "Terms of Services") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TermsOfServiceScreen()),
          );
        } else if (label == "Privacy Policy") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
          );
        } else if (label == "Help & Support") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HelpScreen()),
          );
        }
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
              //  CircleAvatar(
              //   radius: 45,
              //   backgroundImage: photoURL != null
              //       ? NetworkImage(photoURL!)
              //       : AssetImage('assets/images/profile1.png') as ImageProvider,
              // ),
              // const SizedBox(height: 10),
              // Text(
              //   displayName ?? 'Guest User',
              //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              // ),
              CircleAvatar(
                radius: 45,
                backgroundImage: photoURL != null
                    ? NetworkImage(photoURL!)
                    : null, // If photoURL is null, it will show the default initial.
                // ignore: sort_child_properties_last
                child: photoURL == null
                    ? Text(
                        displayName != null && displayName!.isNotEmpty
                            ? displayName![0].toUpperCase()
                            : 'G', // Default letter 'G' for Guest User
                        style:
                            const TextStyle(fontSize: 30, color: Colors.white),
                      )
                    : SizedBox(),
                backgroundColor: Colors
                    .grey[300], // Optional: set background color if no image
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
              // const SizedBox(height: 20),
              // SizedBox(
              //   width: double.infinity,
              //   child: OutlinedButton(
              //     onPressed: () {
              //       print('Edit Profile clicked');
              //     },
              //     style: OutlinedButton.styleFrom(
              //       side: BorderSide(color: Colors.blue),
              //       foregroundColor: Colors.blue,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //     ),
              //     child: const Text('Edit Profile'),
              //   ),
              // ),
              const SizedBox(height: 50),
              // _buildProfileOption(Icons.insert_drive_file, 'Doc Management'),
              _buildProfileOption(Icons.help, 'Help & Support'),
              const SizedBox(height: 20),
              _buildProfileOption(Icons.description, 'Terms of Services'),
              const SizedBox(height: 20),
              _buildProfileOption(Icons.privacy_tip, 'Privacy Policy'),
              const SizedBox(height: 20),
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
