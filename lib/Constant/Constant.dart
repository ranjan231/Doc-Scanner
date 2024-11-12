import 'package:flutter/material.dart';

class Constant {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

   static getRootContext() {
    return Constant.navigatorKey.currentState!.context;
  }
}