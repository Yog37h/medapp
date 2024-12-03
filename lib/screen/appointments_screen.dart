import 'package:flutter/material.dart';

class AppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text('Appointments Details'),
      ),
    );
  }
}
