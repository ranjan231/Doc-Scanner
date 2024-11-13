import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';


class Controller{
   late DocumentScanner documentScanner;
   late DocumentScannerOptions options;
  bool isScanning = false;
  DocumentScanningResult? scanResult;
  List<String> scannedImages = [];
  List<bool> selectedImages = [];
  final ImagePicker picker = ImagePicker();
  List<String> pdfHistory = [];
  String? generatedPdfPath;

  
}