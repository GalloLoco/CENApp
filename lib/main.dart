

import 'package:cenapp/pantallas/inicio.dart';

import 'package:flutter/material.dart';
void main() {
  runApp(CENApp());
}

class CENApp extends StatelessWidget {
  const CENApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CENApp',
      home: LoginScreen(),
    ); 
  }
}
