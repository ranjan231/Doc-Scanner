import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Components/customdialougue.dart';
import 'package:flutterpracticeversion22/Provider/ProfileScreenProvider.dart';
import 'package:flutterpracticeversion22/Screen/ProfileScreen/Manager/ProfileManager.dart';
import 'package:flutterpracticeversion22/Screen/helpscreen/helpscreen.dart';
import 'package:flutterpracticeversion22/Screen/privacypolicyscreen/privacypolicyscreen.dart';
import 'package:flutterpracticeversion22/Screen/termsofservice/termsofservice.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  var manager = ProfileManager();
  var provider = ProfileScreenProvider();

  @override
  void initState() {
    super.initState();
    manager = provider.manager;
    provider.loadUserProfile();
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
              CircleAvatar(
                radius: 45,
                backgroundImage: manager.photoURL != null
                    ? NetworkImage(manager.photoURL!)
                    : null, // If photoURL is null, it will show the default initial.
                // ignore: sort_child_properties_last
                child: manager.photoURL == null
                    ? Text(
                        manager.displayName != null &&
                                manager.displayName!.isNotEmpty
                            ? manager.displayName![0].toUpperCase()
                            : '', // Default letter 'G' for Guest User
                        style:
                            const TextStyle(fontSize: 30, color: Colors.white),
                      )
                    : SizedBox(),
                backgroundColor: Colors
                    .grey[300], // Optional: set background color if no image
              ),

              const SizedBox(height: 10),
              Text(
                manager.displayName ?? "",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                manager.email ?? "",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

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
                  DialogueBox.showLogoutConfirmation(context, provider.logout);
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
