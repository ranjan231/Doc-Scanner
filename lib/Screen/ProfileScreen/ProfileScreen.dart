import 'package:flutter/material.dart';
class  profileScreen extends StatefulWidget {
  const  profileScreen({super.key});

  @override
  State<profileScreen> createState() =>  profileScreenState();
}

class  profileScreenState extends State< profileScreen> {
  

  Widget _buildProfileOption(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(label,style: TextStyle(fontWeight: FontWeight.bold),),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: () {
        print('$label tapped');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            children: [
              // Profile image
              CircleAvatar(
                radius: 45,
                backgroundImage: AssetImage(
                    'assets/images/profile1.png'), // Replace with user's image if available
              ),
              const SizedBox(height: 10),
      
              // User's name and email
              const Text(
                'Fahmi Haecal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                'haecal78@gmail.com',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
      
              // Edit Profile button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    print('Edit Profile clicked');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Colors.blue), // Set the border color to blue
                    foregroundColor: Colors.blue, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
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
      
              // Logout button
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  print('User logged out');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


  