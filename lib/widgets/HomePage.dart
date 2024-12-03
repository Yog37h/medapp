// lib/widgets/HomePage.dart

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40), // Top spacing
            Text(
              "Welcome to HealthCare",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Explore our services:",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),

            // Card for Medicines
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.medical_services, color: Colors.teal, size: 40),
                title: Text("Medicines"),
                subtitle: Text("Order your prescribed medicines"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to MedicinesPage
                  Navigator.pushNamed(context, '/medicines');
                },
              ),
            ),
            SizedBox(height: 20),

            // Card for Medical Equipment
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.health_and_safety, color: Colors.teal, size: 40),
                title: Text("Medical Equipment"),
                subtitle: Text("Browse our health equipment"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to MedicalEquipmentPage
                  Navigator.pushNamed(context, '/equipment');
                },
              ),
            ),
            SizedBox(height: 20),

            // Card for Profile
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.teal, size: 40),
                title: Text("Your Profile"),
                subtitle: Text("Manage your account"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to ProfilePage
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
