import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Constant/Constant.dart';
import 'package:flutterpracticeversion22/Core/GlobalVaribale.dart';
import 'package:flutterpracticeversion22/Screen/CompresspdfScreen/Manager/CompressPdfManager.dart';
import 'package:share/share.dart';
import 'package:path/path.dart';

class CompressPdfprovider extends ChangeNotifier {
  refresh() {
    GlobalVariable.compressProvider.notifyListeners();
  }

  var manager = CompressPdfmanager();

  void toggleDocumentSelection(int index, bool? selected) {
    manager.selectedDocuments[index]['selected'] = selected ?? false;
    refresh();
  }

  double getFileSizeInMB(String filePath) {
    final file = File(filePath);
    if (file.existsSync()) {
      return file.lengthSync() / (1024 * 1024);
    }
    return 0;
  }

  Future<void> selectFromFileManager() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      for (var file in result.files) {
        final exists =
            manager.selectedDocuments.any((doc) => doc['path'] == file.path);
             refresh();
        if (!exists) {
          manager.selectedDocuments.add({
            'title': basename(file.name),
            'path': file.path,
            'selected': false,
          });
           refresh();
        }
      }
      manager.hasDocuments = manager.selectedDocuments.isNotEmpty;
      refresh();
    }
  }

  Future<void> compressSelectedDocuments(double compressionLevel) async {
    final selectedFiles = manager.selectedDocuments
        .where((doc) => doc['selected'] == true)
        .toList();
    if (selectedFiles.isEmpty) {
      ScaffoldMessenger.of(Constant.getRootContext()).showSnackBar(
        SnackBar(
            content: Text('Please select at least one document to compress.')),
      );
      return;
    }

    manager.isCompressing = true;
    refresh();

    // Simulate compression process
    List<String> compressedFiles = [];
    for (var file in selectedFiles) {
      print('Compressing ${file['title']} with level $compressionLevel...');
      compressedFiles.add((file['path']));
      print('chk compress ${compressedFiles}');
    }

    manager.isCompressing = false;
    refresh();

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
}
