import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterpracticeversion22/Screen/CameraScreen/CameraScreen.dart';
import 'package:flutterpracticeversion22/Screen/CompresspdfScreen/CompresspdfScreen.dart';
import 'package:flutterpracticeversion22/Screen/ProfileScreen/ProfileScreen.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Controller/Controller.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var manager = Controller();
  String? userEmail;
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _initializeUserEmail();
    manager.options = DocumentScannerOptions(
      pageLimit: 1,
      documentFormat: DocumentFormat.jpeg,
      mode: ScannerMode.full,
      isGalleryImport: false,
    );
    manager.documentScanner = DocumentScanner(options: manager.options);
  }

  Future<void> _initializeUserEmail() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null && user.providerData.any((info) => info.providerId == 'google.com')) {
    userEmail = user.email;
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('userEmail');
  }
}

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

  Future<void> _startScan() async {
    setState(() => manager.isScanning = true);
    try {
      final result = await manager.documentScanner.scanDocument();
      setState(() {
        manager.scanResult = result;
        if (manager.scanResult!.images.isNotEmpty) {
          manager.scannedImages.addAll(manager.scanResult!.images);
          manager.selectedImages.addAll(
              List.generate(manager.scanResult!.images.length, (_) => false));
        }
        manager.isScanning = false;
      });
      if (manager.scannedImages.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ScannerScreen(scannedImages: manager.scannedImages),
            fullscreenDialog: true,
          ),
        );
      }
    } on PlatformException catch (e) {
      setState(() => manager.isScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning document: ${e.message}')),
      );
    }
  }

  List<Widget> get _widgetOptions => <Widget>[
        _buildHomeScreen(),
        const Center(
            child: Text('Rewards Screen',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold))),
        SizedBox(),
        const Center(
            child: Text('Tools Screen',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold))),
        ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/home.png',
              width: 24,
              height: 24,
              color: _selectedIndex == 0 ? Colors.blue : Colors.black,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/docs.png',
              width: 24,
              height: 24,
              color: _selectedIndex == 1 ? Colors.blue : Colors.black,
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
                  // color: Colors.blue,
                ),
                onPressed: () {
                  _startScan();

                  _onItemTapped(2);
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
              color: _selectedIndex == 3 ? Colors.blue : Colors.black,
            ),
            label: 'Tools',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/user.png',
              width: 24,
              height: 24,
              color: _selectedIndex == 4 ? Colors.blue : Colors.black,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index != 2) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> requestStoragePermission() async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    // Permission granted
  } else {
    // Show a dialog or snackbar to inform the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Storage permission is required to open files.')),
    );
  }
}

  void _openDocument(String filePath) async {
  await requestStoragePermission(); // Ensure permissions are granted
  final result = await OpenFile.open(filePath);
  if (result.type != ResultType.done) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open document: ${result.message}')),
    );
  }
}


  Widget _buildHomeScreen() {
    return Column(
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
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildCardItem(Icons.camera, "Smart Scan", Colors.blue),
                  _buildCardItem(
                      Icons.picture_as_pdf, "PDF Tools", Colors.green),
                  _buildCardItem(Icons.image, "Import Picture", Colors.orange),
                  _buildCardItem(
                      Icons.insert_drive_file, "Import File", Colors.purple),
                  _buildCardItem(Icons.compress, "Compress PDF", Colors.pink),
                  _buildCardItem(
                      Icons.text_fields, "Image to Text", Colors.teal),
                  _buildCardItem(Icons.article, "PDF to Word", Colors.indigo),
                  _buildCardItem(Icons.more_horiz, "More", Colors.brown),
                ],
              ),
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
                    leading: Icon(Icons.insert_drive_file,
                        color: Colors.grey, size: 40),
                    title: Text(data['fileType'] ?? 'Unknown Document'),
                    subtitle: Text(data['timestamp']?.toDate().toString() ??
                        'No date available'),
                    trailing: Icon(Icons.more_vert),
                    onTap: () => _openDocument(data['filePath']),
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
        }
        print('$label clicked');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(iconData, color: color),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
