import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Controller/Controller.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:share/share.dart'; // For sharing files
import 'package:pdf/pdf.dart'; // For generating PDFs
import 'package:pdf/widgets.dart' as pw; // PDF package for Flutter
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For getting valid file paths

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
    manager.selectedImages = List.generate(manager.scannedImages.length,
        (_) => false); // Initialize selection state
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
          manager.selectedImages.addAll(List.generate(
              manager.scanResult!.images.length,
              (_) => false)); 
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

  Future<void> _showShareOptions() {
    TextEditingController fileNameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Share as..."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Text("Select the format to share."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String fileName = fileNameController.text.isEmpty
                    ? 'file_${Random().nextInt(1000000)}' 
                    : fileNameController.text;
                _shareFileAsPDF(fileName);
                Navigator.of(context).pop();
              },
              child: Text("PDF"),
            ),
            TextButton(
              onPressed: () {
                
                _shareFileAsPNG();
                Navigator.of(context).pop();
              },
              child: Text("PNG"),
            ),
          ],
        );
      },
    );
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // Assuming user is authenticated and you have their UID
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _saveDocumentToFirestore(
      String filePath, String fileType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');
    try {
      await firestore.collection('documents').add({
        'filePath': filePath,
        'fileType': fileType,
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': userEmail,
      });
      print('Document saved to Firestore successfully.');
    } catch (e) {
      print('Error saving document to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save document to Firestore')),
      );
    }
  }

  Future<void> _shareFileAsPDF(String fileName) async {
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

      // Share the PDF file
      Share.shareFiles([outputFile.path], text: 'Here is the document as PDF!');

      // Save document to Firestore
      await _saveDocumentToFirestore(outputFile.path, 'PDF');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No images selected to share.')),
      );
    }
  }

  void _shareFileAsPNG() {
    List<String> selectedPaths = _getSelectedImages();
    if (selectedPaths.isNotEmpty) {
      Share.shareFiles(selectedPaths,
          text: 'Here are the scanned images as PNG!');

      // Save each selected image to Firestore as PNG
      for (String imagePath in selectedPaths) {
        _saveDocumentToFirestore(imagePath, 'PNG');
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
      return Center(child: Text('No scan result yet.'));
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
          onTap: () => _toggleImageSelection(index), // Toggle selection on tap
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(8),
            elevation: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(imagePath), fit: BoxFit.cover),
                ),
                if (manager.selectedImages[index])
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
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
            onPressed:
                _showShareOptions, // Show the dialog to choose PDF or PNG
            child: Icon(Icons.share),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(); // Pop back to HomeScreen
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildScanResult()),
          // Other buttons like Generate PDF, View History can remain as they are
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
