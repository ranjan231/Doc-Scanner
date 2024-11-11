import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Screen/HomeScreen/HomeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Develp by Ranjan',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        
        useMaterial3: true,
      ),
      home:  HomeScreen(),
    );
  }
}

