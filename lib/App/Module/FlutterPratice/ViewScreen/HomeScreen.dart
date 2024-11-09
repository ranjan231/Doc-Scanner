import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
       
      ),
      body: Column(
        children: [
          Text('data'),
        ],
      ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
