import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Controller/Controller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:share/share.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScannerScreen extends StatefulWidget {
  final List<String> scannedImages;
  String? gallery;

  ScannerScreen({
    required this.scannedImages,
    this.gallery,
  });

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
    if (widget.gallery == 'gallery') {
      // If gallery is used, mark all images as selected by default
      manager.selectedImages =
          List.generate(manager.scannedImages.length, (_) => true);
    } else {
      // Otherwise, initialize with no selected images
      manager.selectedImages =
          List.generate(manager.scannedImages.length, (_) => false);
    }
    // manager.selectedImages =
    //     List.generate(manager.scannedImages.length, (_) => false);
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
          print('chk image ${manager.scannedImages}');
          manager.scannedImages.addAll(manager.scanResult!.images);
          manager.selectedImages.addAll(
              List.generate(manager.scanResult!.images.length, (_) => false));
        }
        manager.isScanning = false;
      });
    } on PlatformException catch (e) {
      setState(() => manager.isScanning = false);
      Fluttertoast.showToast(
          msg: "Error scanning document: ${e.message}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.blue);
    }
  }

  void _toggleImageSelection(int index) {
    setState(() {
      manager.selectedImages[index] = !manager.selectedImages[index];
    });
  }

  Future<void> _showShareOptions() async {
    TextEditingController fileNameController = TextEditingController();
    String errorMessage = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Share as..."),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fileNameController,
                    decoration: InputDecoration(
                      hintText: "Enter file name",
                      errorText: errorMessage.isNotEmpty ? errorMessage : null,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Select the format to share."),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    String fileName = fileNameController.text.isEmpty
                        ? 'file_${Random().nextInt(1000000)}'
                        : fileNameController.text;
                    final directory = await getApplicationDocumentsDirectory();
                    final outputFile = File('${directory.path}/$fileName.pdf');

                    bool isDuplicate =
                        await _checkForDuplicateFileName(outputFile.path);

                    if (isDuplicate) {
                      setState(() {
                        errorMessage = 'A file with this name already exists.';
                      });
                    } else {
                      await _shareFileAsPDF(fileName);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("PDF"),
                ),
                TextButton(
                  onPressed: () async {
                    String fileName = fileNameController.text.isEmpty
                        ? 'file_${Random().nextInt(1000000)}'
                        : fileNameController.text;
                    List<String> selectedPaths = _getSelectedImages();
                    bool isDuplicate = false;
                    for (String imagePath in selectedPaths) {
                      if (await _checkForDuplicateFileName(imagePath)) {
                        isDuplicate = true;
                        break;
                      }
                    }

                    if (isDuplicate) {
                      setState(() {
                        errorMessage = 'A file with this name already exists.';
                      });
                    } else {
                      _shareFileAsPNG(fileName);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("PNG"),
                ),
              ],
            );
          },
        );
      },
    );
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

      return existingDocs.docs.isNotEmpty;
    } catch (e) {
      print('Error checking for duplicate: $e');
      return false;
    }
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<String> _convertImageToBase64(String imagePath) async {
  final bytes = await File(imagePath).readAsBytes();
  return base64Encode(bytes);
}

  Future<void> _saveDocumentToFirestore(
      User? user, String filePath, String fileType, fileName) async {
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
         // Convert image to Base64
      String base64Image = await _convertImageToBase64(filePath);

        await firestore.collection('documents').add({
          'base64Content': base64Image,
          'filePath': filePath,
          'fileType': fileType,
          'timestamp': FieldValue.serverTimestamp(),
          'userEmail': userEmail,
          'label': fileName,
          'image': widget.scannedImages.first,
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

      await _saveDocumentToFirestore(user, outputFile.path, 'PDF', fileName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No images selected to share.')),
      );
    }
  }

  void _shareFileAsPNG(String fileName) async {
    User? user = FirebaseAuth.instance.currentUser;
    List<String> selectedPaths = _getSelectedImages();

    if (selectedPaths.isNotEmpty) {
      final directory = await getApplicationDocumentsDirectory();
      List<String> updatedPaths = [];

      for (int i = 0; i < selectedPaths.length; i++) {
        final oldFile = File(selectedPaths[i]);
        final newFilePath = '${directory.path}/$fileName.png';
        final newFile = await oldFile.copy(newFilePath);
        updatedPaths.add(newFile.path);

        await _saveDocumentToFirestore(user, newFile.path, 'PNG', fileName);
      }

      // Share the updated PNG files
      Share.shareFiles(updatedPaths);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No images selected to share.')),
      );
    }
  }

  void _pickImagesFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      // Map for fast lookup of existing images
      Map<String, bool> existingSelections = {
        for (int i = 0; i < manager.scannedImages.length; i++)
          manager.scannedImages[i]: manager.selectedImages[i],
      };

      for (XFile image in images) {
        String imagePath = image.path;

        // Check if the image already exists
        if (existingSelections.containsKey(imagePath)) {
          // Retain previous selection status
          continue;
        } else {
          // Add new image and mark it as selected
          manager.scannedImages.add(imagePath);
          manager.selectedImages.add(true); // Mark new image as selected
        }
      }

      setState(() {}); // Refresh UI
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
          onTap: () => _toggleImageSelection(index),
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
          if (widget.gallery==null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Please select an image before you can share.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Expanded(child: _buildScanResult()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.gallery == 'gallery'
              ? _pickImagesFromGallery(context)
              : _startScan();
        },
        child: widget.gallery == 'gallery'
            ? Icon(Icons.image)
            : Icon(Icons.camera),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
