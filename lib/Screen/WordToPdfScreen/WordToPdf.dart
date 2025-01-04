import 'dart:io';
import 'dart:typed_data';
import 'package:aspose_words_cloud/aspose_words_cloud.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WordToPdfConverter extends StatefulWidget {
  @override
  _WordToPdfConverterState createState() => _WordToPdfConverterState();
}

class _WordToPdfConverterState extends State<WordToPdfConverter> {
  File? _wordFile;
  File? _pdfFile;
  bool _isLoading = false; // Track loading state

  Future<void> _pickWordFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null) {
      setState(() {
        _wordFile = File(result.files.single.path!);
        _pdfFile = null;
      });
    }
  }

  Future<void> _convertWordToPdf() async {
    if (_wordFile != null) {
      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        var configuration = Configuration(
            '392a4f9f-2fa0-46cb-9dfe-caa2ae0d05ba',
            'b617662ff97f083516e969b37ba37201');
        var wordsApi = WordsApi(configuration);

        // Upload the Word file
        var localFileContent = await _wordFile!.readAsBytes();
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
        var pdfFilePath = _wordFile!.path.replaceAll('.docx', '.pdf');
        var pdfFile = File(pdfFilePath);

        var bytes = response.buffer.asUint8List();
        await pdfFile.writeAsBytes(bytes);

        setState(() {
          _pdfFile = pdfFile;
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
        msg: "Please pick a Word file first.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _sharePdfFile() async {
    if (_pdfFile != null) {
      await Share.shareFiles([_pdfFile!.path]);
      setState(() {
        _pdfFile = null;
        _wordFile = null;
      });
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
        title: Text('Convert Word to PDF'),
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
                    leading: Icon(Icons.insert_drive_file, color: Colors.blue),
                    title: Text(
                      _wordFile != null
                          ? _wordFile!.path.split('/').last
                          : 'No Word File Selected',
                      style: TextStyle(fontSize: 15),
                    ),
                    trailing: ElevatedButton.icon(
                      icon: Icon(Icons.upload_file, color: Colors.white),
                      label: Text(
                        'Pick File',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _pickWordFile,
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
                        icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                        label: Text(
                          'Convert to PDF',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: _convertWordToPdf,
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
                    'Share PDF File',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _sharePdfFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (_pdfFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'PDF File Ready: ${_pdfFile!.path.split('/').last}',
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
