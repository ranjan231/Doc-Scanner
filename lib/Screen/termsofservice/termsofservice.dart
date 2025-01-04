import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms of Service for our Document Scanner App',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Last updated: January 4, 2025\n\n',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                'Welcome to the our Document Scanner App. By accessing or using our application, you agree to comply with and be bound by the following terms and conditions ("Terms"). If you do not agree to these Terms, you must not use the App.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('1. User Eligibility'),
              Text(
                'You must be at least 13 years of age to use this App. By using this App, you represent and warrant that you meet the eligibility requirements.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('2. User Accounts'),
              Text(
                'Some features of the App may require creating a user account. You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately if you believe your account has been compromised.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('3. Privacy Policy'),
              Text(
                'We value your privacy. Our collection and use of your personal information is governed by our Privacy Policy. By using the App, you consent to the data practices outlined in the Privacy Policy.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('4. Use of the App'),
              Text(
                'You agree to use the App in accordance with applicable laws and not to engage in any unlawful activities or conduct that could damage, disable, or impair the App.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('5. Data Collection and Usage'),
              Text(
                'The App may collect personal data, including document images and other information necessary for its operation. We do not sell or share your data with third parties, except as outlined in our Privacy Policy.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('6. Third-Party Services'),
              Text(
                'Our App may contain links to third-party websites or services that are not owned or controlled by us. We are not responsible for the content or privacy practices of any third-party sites or services.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('7. Limitation of Liability'),
              Text(
                'In no event will we be liable for any damages arising from the use or inability to use the App, including but not limited to data loss, system failure, or other indirect damages.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('8. Changes to Terms of Service'),
              Text(
                'We reserve the right to modify or update these Terms at any time. We will notify you of any significant changes, and continued use of the App after such changes constitutes acceptance of the updated Terms.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('9. Contact Us'),
              Text(
                'If you have any questions or concerns about these Terms, please contact us at itninjas24@gmail.com.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              //   child: Text('Accept'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}