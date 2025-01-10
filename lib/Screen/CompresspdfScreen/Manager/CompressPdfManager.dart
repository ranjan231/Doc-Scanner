import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class CompressPdfmanager {

   List<Map<String, dynamic>> selectedDocuments = [];
  bool hasDocuments = false;
  bool isCompressing = false;
  GoogleSignIn googleSignIn = GoogleSignIn.standard(
    scopes: [drive.DriveApi.driveFileScope],
  );

  

}