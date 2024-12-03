import 'package:flutter/material.dart';

class OrdersPlacedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders Placed'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text('Orders Placed Details'),
      ),
    );
  }
}
