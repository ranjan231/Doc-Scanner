import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Provider/HomeScreenProvier.dart';
import 'package:flutterpracticeversion22/Screen/HomeScreen/Manager/HomeScreenManager.dart';
import 'package:provider/provider.dart';

class DocsScreen extends StatefulWidget {
  const DocsScreen({super.key});

  @override
  State<DocsScreen> createState() => DocsScreenState();
}

class DocsScreenState extends State<DocsScreen> {
  var manager = homeScreenManger();
  var provider = HomeScreenProvider();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeScreenProvider>(builder: (context, value, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
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
              stream: provider.getUserDocuments(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Loading documents count...'),
                    ),
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
                stream: provider.getUserDocuments(),
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
                        leading: Icon(Icons.insert_drive_file,
                            color: Colors.grey, size: 40),
                        // Image.file(
                        //   File(data['image']),
                        //   width: 40,
                        //   height: 40,
                        //   fit: BoxFit.cover,
                        // ),
                        title: Text(data['label'] ?? 'Unknown Document'),
                        trailing: Icon(Icons.more_vert),
                        onTap: () => provider.openDocument(data['filePath']),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
