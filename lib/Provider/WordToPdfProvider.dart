import 'dart:io';
import 'dart:typed_data';

import 'package:aspose_words_cloud/aspose_words_cloud.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Core/GlobalVaribale.dart';
import 'package:flutterpracticeversion22/Screen/WordToPdfScreen/Manager/WordToPdfManager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share/share.dart';

class WordToPdfProvider extends ChangeNotifier {
  refresh() {
    GlobalVariable.wordToPdfProvider.notifyListeners();
  }

  var manager = WordToPdfManager();

  Future<void> pickWordFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null) {
      manager.wordFile = File(result.files.single.path!);
      manager.pdfFile = null;
      refresh();
    }
  }

  Future<void> convertWordToPdf() async {
    if (manager.wordFile != null) {
      manager.isLoading = true; // Start loading
      refresh();

      try {
        var configuration = Configuration(
            '392a4f9f-2fa0-46cb-9dfe-caa2ae0d05ba',
            'b617662ff97f083516e969b37ba37201');
        var wordsApi = WordsApi(configuration);

        // Upload the Word file
        var localFileContent = await manager.wordFile!.readAsBytes();
        var uploadRequest = UploadFileRequest(
            ByteData.view(localFileContent.buffer), 'fileStoredInCloud.docx');
        await wordsApi.uploadFile(uploadRequest);

        // Convert to PDF
        var saveOptionsData = PdfSaveOptionsData()
          ..fileName = 'destStoredInCloud.pdf';
        var saveAsRequest =
            SaveAsRequest('fileStoredInCloud.docx', saveOptionsData);
        await wordsApi.saveAs(saveAsRequest);

        // Download PDF file
        var downloadRequest = DownloadFileRequest('destStoredInCloud.pdf');
        var response = await wordsApi.downloadFile(downloadRequest);
        var pdfFilePath = manager.wordFile!.path.replaceAll('.docx', '.pdf');
        var pdfFile = File(pdfFilePath);

        var bytes = response.buffer.asUint8List();
        await pdfFile.writeAsBytes(bytes);

        manager.pdfFile = pdfFile;
        refresh();

        Fluttertoast.showToast(
          msg: "Conversion successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Conversion failed: ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      } finally {
        manager.isLoading = false; // Stop loading
        refresh();
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please pick a Word file first.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> sharePdfFile() async {
    if (manager.pdfFile != null) {
      await Share.shareFiles([manager.pdfFile!.path]);

      manager.pdfFile = null;
      manager.wordFile = null;
      refresh();
    }
  }
}
