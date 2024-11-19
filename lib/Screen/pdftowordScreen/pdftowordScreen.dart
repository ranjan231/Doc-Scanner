import 'dart:io';
import 'dart:typed_data';
import 'package:aspose_words_cloud/aspose_words_cloud.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class PdfToWordConverter extends StatefulWidget {
  @override
  _PdfToWordScreenState createState() => _PdfToWordScreenState();
}

class _PdfToWordScreenState extends State<PdfToWordConverter> {
  File? _pdfFile;
  File? _wordFile;

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _convertPdfToWord() async {
    if (_pdfFile != null) {
      var configuration = Configuration('392a4f9f-2fa0-46cb-9dfe-caa2ae0d05ba', 'b617662ff97f083516e969b37ba37201');
      var wordsApi = WordsApi(configuration);

      var localFileContent = await _pdfFile!.readAsBytes();
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
      var wordFilePath = _pdfFile!.path.replaceAll('.pdf', '.docx');
      var wordFile = File(wordFilePath);

      var bytes = response.buffer.asUint8List();
      await wordFile.writeAsBytes(bytes);

      setState(() {
        _wordFile = wordFile;
      });
    }
  }

  Future<void> _shareWordFile() async {
    if (_wordFile != null) {
      Share.shareFiles([_wordFile!.path]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF to Word Converter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickPdfFile,
              child: Text('Pick PDF File'),
            ),
            ElevatedButton(
              onPressed: _convertPdfToWord,
              child: Text('Convert to Word'),
            ),
            ElevatedButton(
              onPressed: _shareWordFile,
              child: Text('Share Word File'),
            ),
          ],
        ),
      ),
    );
  }
}
