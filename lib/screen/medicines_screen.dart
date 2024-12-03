import 'package:flutter/material.dart';

class MedicinesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicines'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          'Browse Medicines',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
