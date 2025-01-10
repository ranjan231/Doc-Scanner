import 'dart:io';
import 'dart:typed_data';

import 'package:aspose_words_cloud/aspose_words_cloud.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Core/GlobalVaribale.dart';
import 'package:flutterpracticeversion22/Screen/pdftowordScreen/Manager/PdfToWordManger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share/share.dart';

class PdftoWordProvider extends ChangeNotifier {
  refresh() {
    GlobalVariable.pdftToWordProvider.notifyListeners();
  }

  var manager = PdftoWordManger();

  Future<void> pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      manager.pdfFile = File(result.files.single.path!);
      manager.wordFile = null;
      refresh();
    }
  }

  Future<void> convertPdfToWord() async {
    if (manager.pdfFile != null) {
      manager.isLoading = true; // Start loading
      refresh();

      try {
        var configuration = Configuration(
            '392a4f9f-2fa0-46cb-9dfe-caa2ae0d05ba',
            'b617662ff97f083516e969b37ba37201');
        var wordsApi = WordsApi(configuration);

        var localFileContent = await manager.pdfFile!.readAsBytes();
        var uploadRequest = UploadFileRequest(
            ByteData.view(localFileContent.buffer), 'fileStoredInCloud.pdf');
        await wordsApi.uploadFile(uploadRequest);

        var saveOptionsData = DocxSaveOptionsData()
          ..fileName = 'destStoredInCloud.docx';
        var saveAsRequest =
            SaveAsRequest('fileStoredInCloud.pdf', saveOptionsData);
        await wordsApi.saveAs(saveAsRequest);

        var downloadRequest = DownloadFileRequest('destStoredInCloud.docx');
        var response = await wordsApi.downloadFile(downloadRequest);
        var wordFilePath = manager.pdfFile!.path.replaceAll('.pdf', '.docx');
        var wordFile = File(wordFilePath);

        var bytes = response.buffer.asUint8List();
        await wordFile.writeAsBytes(bytes);

        manager.wordFile = wordFile;
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
        msg: "Please pick a PDF file first.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> shareWordFile() async {
    if (manager.wordFile != null) {
      Share.shareFiles([manager.wordFile!.path]);
    }
  }
}
