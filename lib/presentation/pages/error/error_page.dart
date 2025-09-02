import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget{
  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Image.asset('assets/images/logo_s.png', width: 40, height: 20), 
        ),
        body: Center(
          child: Text('Error Page!!'),
        ),
    );
  }
}