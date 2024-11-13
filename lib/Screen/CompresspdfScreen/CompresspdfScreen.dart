import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutterpracticeversion22/Constant/Constant.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';

class PDFCompressonScreen extends StatefulWidget {
  @override
  _PDFCompressonScreenState createState() => _PDFCompressonScreenState();
}

class _PDFCompressonScreenState extends State<PDFCompressonScreen> {
  List<Map<String, dynamic>> selectedDocuments = [];
  bool hasDocuments = false;
  bool isCompressing = false;
  GoogleSignInAccount? _currentUser;
  GoogleSignIn _googleSignIn = GoogleSignIn.standard(
    scopes: [drive.DriveApi.driveFileScope],
  );

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
    });
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        for (var file in result.files) {
          final exists = selectedDocuments.any((doc) => doc['path'] == file.path);
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

  Future<void> _selectFromDrive() async {
    if (_currentUser == null) {
      await _googleSignIn.signIn();
    }
    final authHeaders = await _currentUser?.authHeaders;
    if (authHeaders == null) return;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    final fileList = await driveApi.files.list(spaces: 'drive', q: "mimeType='application/pdf'");
    setState(() {
      for (var file in fileList.files!) {
        final exists = selectedDocuments.any((doc) => doc['id'] == file.id);
        if (!exists) {
          selectedDocuments.add({
            'title': file.name,
            'id': file.id,
            'selected': false,
          });
        }
      }
      hasDocuments = selectedDocuments.isNotEmpty;
    });
  }

  void _toggleDocumentSelection(int index, bool? selected) {
    setState(() {
      selectedDocuments[index]['selected'] = selected ?? false;
    });
  }

  Future<double?> _showCompressionSettingsDialog(double initialFileSizeMB) async {
    double compressionLevel = 0.1;
    double compressionFactor = 1.0 - compressionLevel;
    double compressedSizeMB = initialFileSizeMB * compressionFactor;

    return showDialog<double>(
      context: Constant.getRootContext(),
      builder: (context) {
        return AlertDialog(
          title: Text('Select Compression Level'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Adjust the slider to set compression level (higher = more compression)'),
                  Slider(
                    value: compressionLevel,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    // label: "${((1.0 - compressionLevel) * 100).toStringAsFixed(0)}% size reduction",
                    onChanged: (double value) {
                      setState(() {
                        compressionLevel = value;
                        compressionFactor = 1.0 - compressionLevel;
                        compressedSizeMB = initialFileSizeMB * compressionFactor;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Text("Estimated size: ${compressedSizeMB.toStringAsFixed(2)} MB"),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, compressionFactor);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _compressSelectedDocuments(double compressionLevel) async {
    final selectedFiles = selectedDocuments.where((doc) => doc['selected'] == true).toList();
    if (selectedFiles.isEmpty) {
      ScaffoldMessenger.of(Constant.getRootContext()).showSnackBar(
        SnackBar(content: Text('Please select at least one document to compress.')),
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
                      ListTile(
                        leading: Icon(Icons.drive_file_rename_outline),
                        title: Text('Drive'),
                        onTap: _selectFromDrive,
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
                            onChanged: (value) => _toggleDocumentSelection(index, value),
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
                      final selectedFiles =
                          selectedDocuments.where((doc) => doc['selected'] == true).toList();
                      if (selectedFiles.isNotEmpty) {
                        double initialFileSizeMB = getFileSizeInMB(selectedFiles.first['path']);
                        double? compressionLevel = await _showCompressionSettingsDialog(initialFileSizeMB);
                        if (compressionLevel != null) {
                          _compressSelectedDocuments(compressionLevel);
                        }
                      }
                    },
                    child: Text('Compress'),
                  ),
                ),
              ],
            ),
    );
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
