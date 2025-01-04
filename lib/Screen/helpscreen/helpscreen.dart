import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Help & Support',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Here you can find help articles, troubleshooting tips, and how to contact our support team.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              _buildSectionTitle('1. How to Use the Document Scanner'),
              Text(
                'To scan a document, follow these simple steps:\n\n'
                '1. Open the app and click on the "Scan" button.\n\n'
                '2. Align your camera with the document you want to scan.\n\n'
                '3. Tap the capture button to take the scan.\n\n'
                '4. Edit the scan if necessary, such as cropping or adjusting the contrast.\n\n'
                '5. Save or share the scanned document as needed.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('2. Troubleshooting'),
              Text(
                'If you are experiencing issues, try the following:\n\n'
                '• Ensure that your camera is focused on the document.\n\n'
                '• Make sure you have sufficient lighting for better scanning.\n\n'
                '• Restart the app if the camera is not functioning properly.\n\n'
                '• Update the app to the latest version to resolve known issues.\n\n'
                'If the issue persists, contact support for further assistance.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('3. Common Issues and Solutions'),
              Text(
                'Here are some common issues and solutions:\n\n'
                '• **Document not scanning properly**: Try adjusting the lighting or re-aligning the camera.\n\n'
                '• **App crashes**: Restart the app or reinstall it from the app store.\n\n'
                '• **Cannot save or share scans**: Ensure you have the necessary permissions for storage access.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              _buildSectionTitle('4. Contact Support'),
              Text(
                'If you need further assistance, feel free to contact our support team. We are here to help!\n\n'
                'Email: itninjas24@gmail.com\n\n'
                'Phone: +1 (800) 123-45675\n\n'
                'We aim to respond within 24-48 hours during business days.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              //   child: Text('Back to Home'),
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