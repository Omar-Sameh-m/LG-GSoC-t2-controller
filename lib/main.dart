import 'package:flutter/material.dart';

void main() {
  runApp(const ControllerApp());
}

class ControllerApp extends StatelessWidget {
  const ControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.orange),
        body: Center(child: Text("Lets start !")),
      ),
    );
  }
}
