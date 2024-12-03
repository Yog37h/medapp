import 'package:flutter/material.dart';

class ProfileViewScreen extends StatelessWidget {
  final String userId;

  ProfileViewScreen(this.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile View'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text('Profile Details for User ID: $userId'),
      ),
    );
  }
}
