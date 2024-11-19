import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocsScreen extends StatefulWidget {
  const DocsScreen({super.key});

  @override
  State<DocsScreen> createState() => DocsScreenState();
}

class DocsScreenState extends State<DocsScreen> {
  Stream<QuerySnapshot> getUserDocuments() async* {
    User? user = FirebaseAuth.instance.currentUser;

    String? userEmail;

    if (user != null &&
        user.providerData.any((info) => info.providerId == 'google.com')) {
      userEmail = user.email;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userEmail = prefs.getString('userEmail');
    }

    if (userEmail != null) {
      yield* FirebaseFirestore.instance
          .collection('documents')
          .where('userEmail', isEqualTo: userEmail)
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      print('User email not found.');
    }
  }

  void _openDocument(String filePath) async {
    await requestStoragePermission();
    final result = await OpenFile.open(filePath);

    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open document: ${result.message}')),
      );
    }
  }

  Future<void> requestStoragePermission() async {
    if (await Permission.manageExternalStorage.request().isGranted) {
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Storage permission is required to open files.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: "Search",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: getUserDocuments(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('Loading documents count...'),
                );
              }

              final documentCount = snapshot.data!.docs.length;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'All($documentCount)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getUserDocuments(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No recent documents.'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Image.file(
                        File(data['image']),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                      title: Text(data['label'] ?? 'Unknown Document'),
                      trailing: Icon(Icons.more_vert),
                      onTap: () => _openDocument(data['filePath']),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
