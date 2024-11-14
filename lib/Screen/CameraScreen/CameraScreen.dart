import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Controller/Controller.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:share/share.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScannerScreen extends StatefulWidget {
  final List<String> scannedImages;

  ScannerScreen({required this.scannedImages});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  var manager = Controller();

  @override
  void initState() {
    super.initState();
    manager.scannedImages = widget.scannedImages;
    manager.options = DocumentScannerOptions(
      pageLimit: 1,
      documentFormat: DocumentFormat.jpeg,
      mode: ScannerMode.full,
      isGalleryImport: false,
    );
    manager.documentScanner = DocumentScanner(options: manager.options);
    manager.selectedImages =
        List.generate(manager.scannedImages.length, (_) => false);
  }

  @override
  void dispose() {
    super.dispose();
    manager.scannedImages.clear();
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
    } on PlatformException catch (e) {
      setState(() => manager.isScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning document: ${e.message}')),
      );
    }
  }

  void _toggleImageSelection(int index) {
  setState(() {
    manager.selectedImages[index] = !manager.selectedImages[index];
  });
}
  // void _toggleImageSelection(int index) {
  //   setState(() {
  //     manager.selectedImages[index] = !manager.selectedImages[index];
  //   });
  // }

Future<void> _showShareOptions() async {
  TextEditingController fileNameController = TextEditingController();
  String errorMessage = '';

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Share as...",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: fileNameController,
                decoration: InputDecoration(
                  hintText: "Enter file name",
                  errorText: errorMessage.isNotEmpty ? errorMessage : null,
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Select the format to share.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text("PDF"),
                    onPressed: () async {
                      await _handleFileSharing(fileNameController, errorMessage, "PDF");
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.image),
                    label: Text("PNG"),
                    onPressed: () async {
                      await _handleFileSharing(fileNameController, errorMessage, "PNG");
                    },
                    style: ElevatedButton.styleFrom(
                     foregroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _handleFileSharing(TextEditingController fileNameController, String errorMessage, String fileType) async {
  String fileName = fileNameController.text.isEmpty
      ? 'file_${Random().nextInt(1000000)}'
      : fileNameController.text;

  final directory = await getApplicationDocumentsDirectory();
  final outputFile = File('${directory.path}/$fileName.${fileType.toLowerCase()}');
  bool isDuplicate = await _checkForDuplicateFileName(outputFile.path);

  if (isDuplicate) {
    setState(() {
      errorMessage = 'A file with this name already exists.';
    });
  } else {
    if (fileType == "PDF") {
      await _shareFileAsPDF(fileName);
    } else {
      _shareFileAsPNG();
    }
    Navigator.of(context).pop();
  }
}



  Future<bool> _checkForDuplicateFileName(String filePath) async {
    String? userEmail;
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null &&
        user.providerData.any((info) => info.providerId == 'google.com')) {
      userEmail = user.email;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userEmail = prefs.getString('userEmail');
    }

    if (userEmail == null) {
      print('No email found for the current user.');
      return false;
    }

    try {
      print(
          'Checking for duplicates for user: $userEmail with fileName: $filePath');

      final existingDocs = await firestore
          .collection('documents')
          .where('userEmail', isEqualTo: userEmail)
          .where('filePath', isEqualTo: filePath)
          .get();

      print('Documents found: ${existingDocs.docs.length}');

      return existingDocs.docs
          .isNotEmpty; 
    } catch (e) {
      print('Error checking for duplicate: $e');
      return false;
    }
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _saveDocumentToFirestore(
      User? user, String filePath, String fileType) async {
    String? userEmail;

    if (user != null &&
        user.providerData.any((info) => info.providerId == 'google.com')) {
      userEmail = user.email;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userEmail = prefs.getString('userEmail');
    }

    if (userEmail == null) {
      print('No email found for the current user.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve user email.')),
      );
      return;
    }

    try {
      final existingDocs = await firestore
          .collection('documents')
          .where('userEmail', isEqualTo: userEmail)
          .where('filePath', isEqualTo: filePath)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('A document with this name already exists.')),
        );
      } else {
        await firestore.collection('documents').add({
          'filePath': filePath,
          'fileType': fileType,
          'timestamp': FieldValue.serverTimestamp(),
          'userEmail': userEmail,
        });
        print('Document saved to Firestore successfully.');
      }
    } catch (e) {
      print('Error saving document to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save document to Firestore')),
      );
    }
  }

  Future<void> _shareFileAsPDF(String fileName) async {
    User? user = FirebaseAuth.instance.currentUser;
    List<String> selectedPaths = _getSelectedImages();
    if (selectedPaths.isNotEmpty) {
      final pdf = pw.Document();
      for (String imagePath in selectedPaths) {
        final imgFile = File(imagePath);
        final imgBytes = await imgFile.readAsBytes();
        final img = pw.MemoryImage(imgBytes);

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Image(img);
            },
          ),
        );
      }

      final directory = await getApplicationDocumentsDirectory();
      final outputFile = File('${directory.path}/$fileName.pdf');
      await outputFile.writeAsBytes(await pdf.save());

      Share.shareFiles([outputFile.path], text: 'Here is the document as PDF!');

      await _saveDocumentToFirestore(user, outputFile.path, 'PDF');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No images selected to share.')),
      );
    }
  }

  void _shareFileAsPNG() {
    User? user = FirebaseAuth.instance.currentUser;
    List<String> selectedPaths = _getSelectedImages();
    if (selectedPaths.isNotEmpty) {
      Share.shareFiles(selectedPaths,
          text: 'Here are the scanned images as PNG!');

      for (String imagePath in selectedPaths) {
        _saveDocumentToFirestore(user, imagePath, 'PNG');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No images selected to share.')),
      );
    }
  }

  List<String> _getSelectedImages() {
    List<String> selectedPaths = [];
    for (int i = 0; i < manager.selectedImages.length; i++) {
      if (manager.selectedImages[i]) {
        selectedPaths.add(manager.scannedImages[i]);
      }
    }
    return selectedPaths;
  }

  Widget _buildScanResult() {
  if (manager.scannedImages.isEmpty) {
    return Center(
      child: Text(
        'No scan result yet.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemCount: manager.scannedImages.length,
    itemBuilder: (context, index) {
      final imagePath = manager.scannedImages[index];
      return GestureDetector(
        onTap: () => _toggleImageSelection(index),
        child: Stack(
          children: [
            
            Card(
              
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.all(8),
              elevation: 5,
              child: ClipRRect(
                
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (manager.selectedImages[index])
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.greenAccent,
                      size: 40,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: _showShareOptions,
            child: Icon(Icons.share),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildScanResult()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startScan,
        child: Icon(Icons.camera),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
