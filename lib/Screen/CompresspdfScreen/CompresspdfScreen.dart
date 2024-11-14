import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutterpracticeversion22/Constant/Constant.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:share/share.dart';

class PDFCompressonScreen extends StatefulWidget {
  @override
  _PDFCompressonScreenState createState() => _PDFCompressonScreenState();
}

class _PDFCompressonScreenState extends State<PDFCompressonScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> selectedDocuments = [];
  bool hasDocuments = false;
  bool isCompressing = false;
  GoogleSignIn _googleSignIn = GoogleSignIn.standard(
    scopes: [drive.DriveApi.driveFileScope],
  );

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((account) {});
    _googleSignIn.signInSilently();
  }

  // Helper function to get file size in MB
  double getFileSizeInMB(String filePath) {
    final file = File(filePath);
    if (file.existsSync()) {
      return file.lengthSync() / (1024 * 1024);
    }
    return 0;
  }

  Future<void> _selectFromFileManager() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        for (var file in result.files) {
          final exists =
              selectedDocuments.any((doc) => doc['path'] == file.path);
          if (!exists) {
            selectedDocuments.add({
              'title': basename(file.name),
              'path': file.path,
              'selected': false,
            });
          }
        }
        hasDocuments = selectedDocuments.isNotEmpty;
      });
    }
  }

  void _toggleDocumentSelection(int index, bool? selected) {
    setState(() {
      selectedDocuments[index]['selected'] = selected ?? false;
    });
  }

  Future<double?> _showCompressionSettingsDialog(
      double initialFileSizeMB) async {
    double compressionLevel = 0.5; // Default compression level
    double compressedSizeMB = initialFileSizeMB * (1.0 - compressionLevel);

    return showDialog<double>(
      context: Constant.getRootContext(),
      builder: (context) {
        return AlertDialog(
          title: Lottie.asset(
            'assets/animations/animation.json',
            height: 150.0,
            repeat: true,
            reverse: true,
            animate: true,
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  Text(
                    "Compressed Successfully !",
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                  ),
                ],
              );
            },
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: BorderSide(color: Colors.blue),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(100, 40),
              ),
              child: const Text('Cancel'),
            ),
           SizedBox(width: 10,),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 1.0 - compressionLevel);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(100, 40),
              ),
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _compressSelectedDocuments(double compressionLevel) async {
    final selectedFiles =
        selectedDocuments.where((doc) => doc['selected'] == true).toList();
    if (selectedFiles.isEmpty) {
      ScaffoldMessenger.of(Constant.getRootContext()).showSnackBar(
        SnackBar(
            content: Text('Please select at least one document to compress.')),
      );
      return;
    }

    setState(() {
      isCompressing = true;
    });

    // Simulate compression process
    List<String> compressedFiles = [];
    for (var file in selectedFiles) {
      print('Compressing ${file['title']} with level $compressionLevel...');
      compressedFiles.add((file['path']));
      print('chk compress ${compressedFiles}');
    }

    setState(() {
      isCompressing = false;
    });

    ScaffoldMessenger.of(Constant.getRootContext()).showSnackBar(
      SnackBar(content: Text('Documents compressed successfully!')),
    );

    if (compressedFiles.isNotEmpty) {
      await Share.shareFiles(
        compressedFiles,
        subject: 'Compressed PDF Documents',
        text: 'Here are the compressed PDF documents.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('PDF Compression'),
      ),
      body: isCompressing
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: Icon(Icons.folder),
                        title: Text('File Manager'),
                        onTap: _selectFromFileManager,
                      ),
                      Divider(),
                      if (!hasDocuments)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('No selected documents'),
                          ),
                        ),
                      if (hasDocuments)
                        ...selectedDocuments.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> document = entry.value;
                          return CheckboxListTile(
                            title: Text(document['title']),
                            subtitle: Text(document['path'] ?? ''),
                            value: document['selected'],
                            onChanged: (value) =>
                                _toggleDocumentSelection(index, value),
                          );
                        }).toList(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      final selectedFiles = selectedDocuments
                          .where((doc) => doc['selected'] == true)
                          .toList();
                      if (selectedFiles.isNotEmpty) {
                        double initialFileSizeMB =
                            getFileSizeInMB(selectedFiles.first['path']);
                        print('initialFileSizeMB ${initialFileSizeMB}');
                        double? compressionLevel =
                            await _showCompressionSettingsDialog(
                                initialFileSizeMB);
                        print(' compress level ${compressionLevel}');
                        if (compressionLevel != null) {
                          _compressSelectedDocuments(compressionLevel);
                        }
                      }
                      print('object');
                    },
                    child: Text('Compress'),
                  ),
                ),
              ],
            ),
    );
  }
}
