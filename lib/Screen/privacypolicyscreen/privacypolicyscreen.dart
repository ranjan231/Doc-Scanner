import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy for our Document Scanner App',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Last updated: January 4, 2025\n\n',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                'Your privacy is important to us. This Privacy Policy explains how we collect, use, and share information when you use our document scanner app. By using the App, you agree to the practices outlined in this policy.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('1. Information We Collect'),
              const Text(
                'When you use our App, we may collect the following types of information:\n\n'
                '• Personal Data: Including your name, email address, and any other data you provide to create an account.\n\n'
                '• Device Information: Information about your device, including model, operating system version, and unique identifiers.\n\n'
                '• Document Data: Scanned documents and images may be stored on your device temporarily for processing and use in the App.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('2. How We Use Your Information'),
              Text(
                'We use the information we collect for the following purposes:\n\n'
                '• To provide, operate, and maintain the App.\n\n'
                '• To personalize your experience and improve our services.\n\n'
                '• To communicate with you about updates, support, or other information relevant to the App.\n\n'
                '• To analyze usage patterns and enhance the performance of the App.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('3. Data Sharing and Disclosure'),
              Text(
                'We do not sell, trade, or rent your personal information to third parties. However, we may share your information with:\n\n'
                '• Service providers who assist in the operation of the App.\n\n'
                '• Legal authorities if required by law or to protect our rights.\n\n'
                '• In the event of a merger or acquisition, your information may be transferred as part of the business transaction.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('4. Data Security'),
              Text(
                'We take reasonable measures to protect the security of your data, but no method of transmission over the internet or method of electronic storage is 100% secure. We cannot guarantee absolute security.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('5. Your Rights'),
              Text(
                'Depending on your location, you may have the right to:\n\n'
                '• Access the information we hold about you.\n\n'
                '• Request the correction or deletion of your personal information.\n\n'
                '• Object to or restrict certain uses of your data.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('6. Changes to This Privacy Policy'),
              Text(
                'We reserve the right to update or change this Privacy Policy at any time. If we make significant changes, we will notify you by updating the "Last updated" date and, in some cases, providing additional notice.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('7. Contact Us'),
              Text(
                'If you have any questions or concerns about this Privacy Policy or our data practices, please contact us at support@yourapp.com.\n\n',
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