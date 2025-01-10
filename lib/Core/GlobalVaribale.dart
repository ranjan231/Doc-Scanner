

import 'package:flutterpracticeversion22/Provider/CompressPdfProvider.dart';
import 'package:flutterpracticeversion22/Provider/HomeScreenProvier.dart';
import 'package:flutterpracticeversion22/Provider/PdfToWordProvider.dart';
import 'package:flutterpracticeversion22/Provider/ProfileScreenProvider.dart';
import 'package:flutterpracticeversion22/Provider/WordToPdfProvider.dart';

class GlobalVariable {
  static HomeScreenProvider homeProvider = HomeScreenProvider();
  static ProfileScreenProvider profileProvider = ProfileScreenProvider();
  static CompressPdfprovider compressProvider = CompressPdfprovider();
  static PdftoWordProvider pdftToWordProvider = PdftoWordProvider();
  static WordToPdfProvider wordToPdfProvider = WordToPdfProvider();
}