
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterpracticeversion22/Provider/HomeScreenProvier.dart';
import 'package:flutterpracticeversion22/Screen/CompresspdfScreen/ViewScreen/CompresspdfScreen.dart';
import 'package:flutterpracticeversion22/Screen/DocScreen/DocsScreen.dart';
import 'package:flutterpracticeversion22/Screen/HomeScreen/Manager/HomeScreenManager.dart';
import 'package:flutterpracticeversion22/Screen/ProfileScreen/ViewScreen/ProfileScreen.dart';
import 'package:flutterpracticeversion22/Screen/WordToPdfScreen/ViewScreen/WordToPdf.dart';
import 'package:flutterpracticeversion22/Screen/pdftowordScreen/ViewScreen/pdftowordScreen.dart';

import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var manager = homeScreenManger();
  var provider = HomeScreenProvider();
  @override
  void initState() {
    super.initState();
    provider.initializeUserEmail();
     manager=provider.manager;
    manager.options = DocumentScannerOptions(
      pageLimit: 1,
      documentFormat: DocumentFormat.jpeg,
      mode: ScannerMode.full,
      isGalleryImport: false,
    );
    manager.documentScanner = DocumentScanner(options: manager.options);
  }

  List<Widget> get _widgetOptions => <Widget>[
        _buildHomeScreen(),
        DocsScreen(),
        SizedBox(),
        const Center(
            child: Text('Tools Screen',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold))),
        ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeScreenProvider>(builder: (context, value, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: _widgetOptions[provider.selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: provider.selectedIndex,
          onTap: provider.onItemTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 16,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/home.png',
                width: 24,
                height: 24,
                color: provider.selectedIndex == 0 ? Colors.blue : Colors.black,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/docs.png',
                width: 24,
                height: 24,
                color: provider.selectedIndex == 1 ? Colors.blue : Colors.black,
              ),
              label: 'Docs',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Image.asset(
                    'assets/images/camera.png',
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    provider.startScan();
                    provider.refresh();

                    provider.onItemTapped(2);
                    provider.refresh();
                  },
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/tools.png',
                width: 24,
                height: 24,
                color: provider.selectedIndex == 3 ? Colors.blue : Colors.black,
              ),
              label: 'Tools',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/user.png',
                width: 24,
                height: 24,
                color: provider.selectedIndex == 4 ? Colors.blue : Colors.black,
              ),
              label: 'Profile',
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHomeScreen() {
    return Column(
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
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              children: [
                _buildCardItem(Icons.camera, "Smart Scan", Colors.blue),
                _buildCardItem(Icons.image, "Import Image", Colors.green),
                _buildCardItem(
                    Icons.picture_as_pdf, "Word to PDF", Colors.orange),
                _buildCardItem(Icons.compress, "Compress PDF", Colors.pink),
                _buildCardItem(Icons.text_fields, "Image to Text", Colors.teal),
                _buildCardItem(Icons.article, "PDF to Word", Colors.indigo),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Recent Docs",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
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
                  print('indera: ${data['image']}');
                  return ListTile(
                    leading:
                        // (data['image'] != null && data['image'].isNotEmpty)
                        //     ? (data['image'].startsWith('http')
                        //         ? Image.network(
                        //             data['image'],
                        //             width: 40,
                        //             height: 40,
                        //             fit: BoxFit.cover,
                        //           )
                        //         : (File(data['image']).existsSync()
                        //             ? Image.file(
                        //                 File(data['image']),
                        //                 width: 60,
                        //                 height: 60,
                        //                 fit: BoxFit.contain,
                        //               )
                        //             : Icon(Icons.broken_image,
                        //                 color: Colors.red, size: 40)))
                        //     :
                        Icon(Icons.insert_drive_file,
                            color: Colors.grey, size: 40),
                    title: Text(data['label'] ?? 'Unknown Document'),
                    subtitle: Text(data['timestamp']?.toDate().toString() ??
                        'No date available'),
                    trailing: Icon(Icons.more_vert),
                    onTap: () => provider.openDocument(data['filePath']),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
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
        // image
        print('$label tapped');
      },
    );
  }

  Widget _buildCardItem(IconData iconData, String label, Color color) {
    return GestureDetector(
      onTap: () {
        if (label == 'Compress PDF') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PDFCompressonScreen(),
              fullscreenDialog: true,
            ),
          );
        } else if (label == 'Image to Text') {
          // imageToText(context);
          provider.selectImage(context);
        } else if (label == 'PDF to Word') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PdfToWordConverter(),
              fullscreenDialog: true,
            ),
          );
        } else if (label == 'Smart Scan') {
          provider.startScan();
          provider.refresh();
        } else if (label == 'Word to PDF') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WordToPdfConverter(),
              fullscreenDialog: true,
            ),
          );
        } else if (label == 'Import Image') {
          provider.pickImagesFromGallery(context);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(iconData, color: color),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
