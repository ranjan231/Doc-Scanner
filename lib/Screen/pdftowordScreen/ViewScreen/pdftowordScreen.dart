import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Provider/PdfToWordProvider.dart';
import 'package:flutterpracticeversion22/Screen/pdftowordScreen/Manager/PdfToWordManger.dart';
import 'package:provider/provider.dart';

class PdfToWordConverter extends StatefulWidget {
  @override
  _PdfToWordScreenState createState() => _PdfToWordScreenState();
}

class _PdfToWordScreenState extends State<PdfToWordConverter> {
  var manager = PdftoWordManger();
  var provider = PdftoWordProvider();

  @override
  void initState() {
    super.initState();
    manager = provider.manager;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PdftoWordProvider>(builder: (context, value, child) {
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
                        manager.pdfFile != null
                            ? manager.pdfFile!.path.split('/').last
                            : 'No PDF Selected',
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: ElevatedButton.icon(
                        icon: Icon(Icons.upload_file, color: Colors.white),
                        label: Text(
                          'Pick File',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: provider.pickPdfFile,
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
                  manager.isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton.icon(
                          icon: Icon(Icons.transform, color: Colors.white),
                          label: Text(
                            'Convert to Word',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: provider.convertPdfToWord,
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
                    onPressed: provider.shareWordFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (manager.wordFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Word File Ready: ${manager.wordFile!.path.split('/').last}',
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
    });
  }
}
