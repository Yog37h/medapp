import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatelessWidget {
  final double totalAmount;

  PaymentMethodScreen({required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Method'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount: ₹$totalAmount',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Select Payment Method:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text('Credit/Debit Card'),
              leading: Icon(Icons.credit_card),
              onTap: () {
                // Navigate to card payment screen or logic
              },
            ),
            ListTile(
              title: Text('UPI'),
              leading: Icon(Icons.payment),
              onTap: () {
                // Navigate to UPI payment screen or logic
              },
            ),
            ListTile(
              title: Text('Cash on Delivery'),
              leading: Icon(Icons.money),
              onTap: () {
                // Handle Cash on Delivery logic
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle payment confirmation logic
                  _showPaymentSuccessDialog(context);
                },
                child: Text('Confirm Payment'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  elevation: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Payment Successful"),
          content: Text("Your payment has been successfully processed."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to a success screen or home page
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
