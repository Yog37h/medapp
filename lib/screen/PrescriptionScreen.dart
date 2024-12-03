import 'package:flutter/material.dart';

class PrescriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text('Prescription Details'),
      ),
    );
  }
}
