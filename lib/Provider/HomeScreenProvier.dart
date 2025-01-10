import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Constant/Constant.dart';
import 'package:flutterpracticeversion22/Core/GlobalVaribale.dart';
import 'package:flutterpracticeversion22/Screen/CameraScreen/CameraScreen.dart';
import 'package:flutterpracticeversion22/Screen/HomeScreen/Manager/HomeScreenManager.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenProvider extends ChangeNotifier {
  refresh() {
    GlobalVariable.homeProvider.notifyListeners();
  }

  var manager = homeScreenManger();
 
   int selectedIndex = 0;

  void onItemTapped(int index) {
    if (index != 2) {
      selectedIndex = index;
      refresh();
    }
  }

  void displayExtractedText(BuildContext context, String extractedText) {
    TextEditingController textController =
        TextEditingController(text: extractedText);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Extracted Text",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: textController,
              maxLines: null,
              readOnly: true,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Extracted text will appear here",
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: extractedText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("All text copied to clipboard!")),
                );
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.copy, size: 18),
              label: Text("Copy All"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> selectImage(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Select Image Source",
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: Text("Camera", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: Text("Gallery", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );

    if (source == null) return;

    final pickedImage = await manager.picker.pickImage(source: source);
    if (pickedImage == null) return;

    final inputImage = InputImage.fromFilePath(pickedImage.path);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    displayExtractedText(context, recognizedText.text);
  }

  Future<void> initializeUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        user.providerData.any((info) => info.providerId == 'google.com')) {
      manager.userEmail = user.email;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      manager.userEmail = prefs.getString('userEmail');
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

  Future<void> startScan() async {
   
    manager.isScanning = true;
    refresh();

    try {
      
      final result = await manager.documentScanner.scanDocument();

      manager.scanResult = result;
      refresh();

      if (manager.scanResult!.images.isNotEmpty) {
        manager.scannedImages.addAll(manager.scanResult!.images);
        manager.selectedImages.addAll(
            List.generate(manager.scanResult!.images.length, (_) => false));
      }
      manager.isScanning = false;
      refresh();
      if (manager.scannedImages.isNotEmpty) {
        Navigator.of(Constant.getRootContext()).push(
          MaterialPageRoute(
            builder: (context) => ScannerScreen(
              scannedImages: manager.scannedImages,
            ),
            fullscreenDialog: true,
          ),
        );
      }
    } on PlatformException catch (e) {
      manager.isScanning = false;
      refresh();
      print('afgb ${e}');
    }
  }

  void pickImagesFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      // Convert selected images into a list of file paths
      List<String> imagePaths = images.map((image) => image.path).toList();

      // Navigate to the ScannerScreen with selected images
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ScannerScreen(scannedImages: imagePaths, gallery: 'gallery'),
          fullscreenDialog: true,
        ),
      );
    } else {
      // Show a message if no image is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No images selected.')),
      );
    }
  }

  void openDocument(String filePath) async {
    // await requestStoragePermission();

    File file = File(filePath);
    if (file.existsSync()) {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(Constant.getRootContext()).showSnackBar(
          SnackBar(content: Text('Could not open document: ${result.message}')),
        );
      }
    } else {
      // File doesn't exist locally, fetch from Firestore and recreate it
      String? base64Content;

      final query = await FirebaseFirestore.instance
          .collection('documents')
          .where('filePath', isEqualTo: filePath)
          .get();

      if (query.docs.isNotEmpty) {
        base64Content = query.docs.first['base64Content'];
      }

      if (base64Content != null) {
        Uint8List bytes = base64Decode(base64Content);
        await file.writeAsBytes(bytes);

        final result = await OpenFile.open(file.path);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(Constant.getRootContext()).showSnackBar(
            SnackBar(
                content: Text('Could not open document: ${result.message}')),
          );
        }
      } else {
        ScaffoldMessenger.of(Constant.getRootContext()).showSnackBar(
          SnackBar(content: Text('File not found on server.')),
        );
      }
    }
  }
}
