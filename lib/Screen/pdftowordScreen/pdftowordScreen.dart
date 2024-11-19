import 'dart:io';
import 'dart:typed_data';
import 'package:aspose_words_cloud/aspose_words_cloud.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PdfToWordConverter extends StatefulWidget {
  @override
  _PdfToWordScreenState createState() => _PdfToWordScreenState();
}

class _PdfToWordScreenState extends State<PdfToWordConverter> {
  File? _pdfFile;
  File? _wordFile;
  bool _isLoading = false; // Track loading state

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
        _wordFile=null;
      });
    }
  }

  Future<void> _convertPdfToWord() async {
    if (_pdfFile != null) {
      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        var configuration = Configuration(
            '392a4f9f-2fa0-46cb-9dfe-caa2ae0d05ba',
            'b617662ff97f083516e969b37ba37201');
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
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please pick a PDF file first.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Convert PDF to Word'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf, color: Colors.blue),
                    title: Text(
                      _pdfFile != null
                          ? _pdfFile!.path.split('/').last
                          : 'No PDF Selected',
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: ElevatedButton.icon(
                      icon: Icon(Icons.upload_file, color: Colors.white),
                      label: Text(
                        'Pick File',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _pickPdfFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton.icon(
                        icon: Icon(Icons.transform, color: Colors.white),
                        label: Text(
                          'Convert to Word',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: _convertPdfToWord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.share, color: Colors.white),
                  label: Text(
                    'Share Word File',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _shareWordFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (_wordFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'Word File Ready: ${_wordFile!.path.split('/').last}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
