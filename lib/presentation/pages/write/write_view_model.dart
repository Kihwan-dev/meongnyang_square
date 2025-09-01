import 'package:flutter/material.dart';

class WriteViewModel {
  final tagController = TextEditingController();
  final contentController = TextEditingController();
  static const maxLength = 200;

  void dispose() {
    tagController.dispose();
    contentController.dispose();
  }
}