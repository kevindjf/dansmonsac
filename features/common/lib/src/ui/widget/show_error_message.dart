import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowErrorMessage {

  static show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}