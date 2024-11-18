// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;
// import 'package:flutter_archive/flutter_archive.dart';
// import 'package:share/share.dart';

// class PdftowordScreen extends StatefulWidget {
//   const PdftowordScreen({super.key});

//   @override
//   State<PdftowordScreen> createState() => _PdftowordScreenState();
// }

// class _PdftowordScreenState extends State<PdftowordScreen> {
//   File? _selectedPdf;
//   String _extractedText = '';
//   File? _convertedWordFile;
//   bool _isLoading = false;

//   // Method to pick a PDF file
//   Future<void> _pickPdfFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//     );
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         _selectedPdf = File(result.files.single.path!);
//       });
//     }
//   }

//   // Method to extract text from the selected PDF
//   Future<void> _extractTextFromPdf() async {
//     if (_selectedPdf != null) {
//       setState(() {
//         _isLoading = true;
//       });

//       // Load the PDF document using syncfusion
//       final syncfusion.PdfDocument document =
//           syncfusion.PdfDocument(inputBytes: await _selectedPdf!.readAsBytes());

//       // Extract text from all pages
//       String extractedText =
//           syncfusion.PdfTextExtractor(document).extractText();

//       setState(() {
//         _extractedText = extractedText;
//         _isLoading = false;
//       });

//       // Dispose the document after use
//       document.dispose();
//     }
//   }

//   // Method to create a Word document from the extracted text
//   Future<void> _createWordFile() async {
//     if (_extractedText.isNotEmpty) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         // Create a temporary directory for the DOCX structure
//         Directory tempDir = await getTemporaryDirectory();
//         Directory docxDir = Directory('${tempDir.path}/docx_temp/word');

//         // Ensure the 'word' subdirectory is created
//         await docxDir.create(recursive: true);

//         // Ensure that the '_rels' subdirectory is created as well
//         Directory relsDir = Directory('${docxDir.path}/_rels');
//         await relsDir.create(recursive: true);

//         // Step 1: Create the word/document.xml file with proper structure
//         File documentXml = File('${docxDir.path}/document.xml');
//         String documentXmlContent = '''
// <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
// <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006">
//   <w:body>
//     <w:p>
//       <w:r>
//         <w:t>${_extractedText.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('\n', '<w:t></w:t>')}</w:t>
//       </w:r>
//     </w:p>
//   </w:body>
// </w:document>''';
//         await documentXml.writeAsString(documentXmlContent);

//         // Step 2: Create word/styles.xml (this is a minimal valid style file)
//         File stylesXml = File('${docxDir.path}/styles.xml');
//         String stylesXmlContent = '''
// <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
// <w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
//   <w:style w:type="paragraph" w:styleId="Normal">
//     <w:name w:val="Normal"/>
//     <w:basedOn w:val="Normal"/>
//     <w:next w:val="Normal"/>
//     <w:rPr/>
//   </w:style>
// </w:styles>''';
//         await stylesXml.writeAsString(stylesXmlContent);

//         // Step 3: Create content types file [Content_Types].xml
//         File contentTypesXml = File('${docxDir.path}/[Content_Types].xml');
//         String contentTypesXmlContent = '''
// <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
// <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
//   <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
//   <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
//   <Override PartName="/word/_rels/document.xml.rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
// </Types>''';
//         await contentTypesXml.writeAsString(contentTypesXmlContent);

//         // Step 4: Create _rels/document.xml.rels file for relationships
//         File documentRels = File('${docxDir.path}/_rels/document.xml.rels');
//         String documentRelsContent = '''
// <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
// <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
//   <Relationship Target="styles.xml" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Id="rId1"/>
// </Relationships>''';
//         await documentRels.writeAsString(documentRelsContent);

//         // Step 5: Create the DOCX ZIP archive using `flutter_archive`
//         File docxFile = File("${tempDir.path}/converted_from_pdf.docx");
//         await _zipDirectory(docxDir, docxFile);

//         setState(() {
//           _convertedWordFile = docxFile;
//           _isLoading = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("PDF converted to Word successfully!")),
//         );
//       } catch (e) {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Error generating Word file.")),
//         );
//         print('Error during DOCX generation: $e');
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No extracted text to convert.")),
//       );
//     }
//   }

//   // Helper method to ZIP the directory into a DOCX file
//   Future<void> _zipDirectory(Directory sourceDir, File zipFile) async {
//     try {
//       await ZipFile.createFromDirectory(
//         sourceDir: sourceDir,
//         zipFile: zipFile,
//         recurseSubDirs: true,
//       );
//     } catch (e) {
//       print("Error while zipping the directory: $e");
//     }
//   }

//   Future<void> _shareFile() async {
//     try {
//       if (_convertedWordFile != null && await _convertedWordFile!.exists()) {
//         // Share the Word file
//         Share.shareFiles([_convertedWordFile!.path],
//             text: "Sharing Word File!");
//       } else if (_extractedText.isNotEmpty) {
//         // If no Word file but text exists, share text instead
//         Share.share(_extractedText); // This will share the extracted text.
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("No file or text to share.")),
//         );
//       }
//     } catch (e) {
//       debugPrint("Error sharing file: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Error sharing the file.")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("PDF to Word Converter"),
//         backgroundColor: Colors.deepPurple,
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ElevatedButton.icon(
//               onPressed: _pickPdfFile,
//               icon: const Icon(Icons.upload_file),
//               label: const Text("Pick a PDF"),
//               style:
//                   ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
//             ),
//             const SizedBox(height: 20),
//             if (_selectedPdf != null)
//               Text(
//                 "Selected File: ${_selectedPdf!.path.split('/').last}",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             const SizedBox(height: 20),
//             if (_selectedPdf != null)
//               ElevatedButton.icon(
//                 onPressed: _extractTextFromPdf,
//                 icon: const Icon(Icons.swap_horiz),
//                 label: const Text("Extract Text"),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//               ),
//             const SizedBox(height: 10),
//             if (_extractedText.isNotEmpty)
//               Container(
//                 padding: const EdgeInsets.all(8.0),
//                 color: Colors.grey[200],
//                 child: Text(
//                   _extractedText,
//                   style: const TextStyle(fontSize: 12),
//                   maxLines: 10,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             const SizedBox(height: 20),
//             if (_extractedText.isNotEmpty)
//               ElevatedButton.icon(
//                 onPressed: _createWordFile,
//                 icon: const Icon(Icons.create),
//                 label: const Text("Create Word File"),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//               ),
//             const SizedBox(height: 10),
//             if (_convertedWordFile != null)
//               ElevatedButton.icon(
//                 onPressed: _shareFile,
//                 icon: const Icon(Icons.share),
//                 label: const Text("Share Word File"),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               ),
//             const SizedBox(height: 20),
//             if (_isLoading)
//               Column(
//                 children: const [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 10),
//                   Text("Processing... Please wait."),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart'; // For creating a .docx file
import 'package:syncfusion_flutter_pdf/pdf.dart'; // For extracting text from PDF

class PdfToWordConverter extends StatefulWidget {
  @override
  _PdfToWordConverterState createState() => _PdfToWordConverterState();
}

class _PdfToWordConverterState extends State<PdfToWordConverter> {
  String? _filePath;

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
      // Call your conversion function here
      await _convertPdfToWord(_filePath!);
    }
  }

  Future<void> _convertPdfToWord(String pdfPath) async {
    final directory = await getApplicationDocumentsDirectory();
    String wordFilePath = '${directory.path}/converted.docx';

    // Extract text from PDF
    String extractedText = await _extractTextFromPdf(pdfPath);

    // Create a valid .docx file with the extracted text
    final docxContent = _createDocxContent(extractedText);
    File(wordFilePath).writeAsBytesSync(docxContent!);

    // Ensure the file is created successfully
    if (await File(wordFilePath).exists()) {
      _shareFile(wordFilePath);
    } else {
      // Handle error
      print("Error: Word file not created");
    }
  }

  Future<String> _extractTextFromPdf(String pdfPath) async {
    // Load the PDF document
    final File file = File(pdfPath);
    final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());

    // Extract text from the entire document
    String text = PdfTextExtractor(document).extractText();

    // Dispose the document
    document.dispose();

    return text;
  }

  List<int>? _createDocxContent(String text) {
    final archive = Archive();

        // Add the required [Content_Types].xml file
    archive.addFile(ArchiveFile('[Content_Types].xml', 38, utf8.encode('''
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
        <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
        <Default Extension="xml" ContentType="application/xml"/>
        <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main"/>
        <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles"/>
      </Types>
    ''')));

    // Add the _rels folder and the document relationships file
    archive.addFile(ArchiveFile('_rels/.rels', 37, utf8.encode('''
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
        <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
      </Relationships>
    ''')));

    // Add the word/_rels folder and the document relationships file
    archive.addFile(ArchiveFile('word/_rels/document.xml.rels', 73, utf8.encode('''
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
        <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
      </Relationships>
    ''')));

    // Create a .docx file
    return ZipEncoder().encode(archive);
  }

  void _shareFile(String filePath) {
    // Share the Word file
    Share.shareFiles([filePath], text: 'Here is your converted Word file!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF to Word Converter'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _pickPdf,
          child: Text('Pick PDF and Convert to Word'),
        ),
      ),
    );
  }
}