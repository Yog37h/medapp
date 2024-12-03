// lib/screens/consult_us_screen.dart

import 'package:flutter/material.dart';
import 'hospital_detail_screen.dart';
import '../model/hospital_model.dart';
import '../data/hospital_data.dart'; // Import the hospital data

class ConsultUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Consult Us",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: hospitalData.length,
          itemBuilder: (context, index) {
            final hospital = hospitalData[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              elevation: 4,
              // Shadow effect for depth
              margin: EdgeInsets.symmetric(vertical: 8),
              // Spacing between cards
              child: ListTile(
                leading: Icon(
                  Icons.local_hospital,
                  color: Colors.teal, // Teal color to match theme
                  size: 40, // Increased icon size for better visibility
                ),
                title: Text(
                  hospital.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),

                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.teal.shade400,
                  size: 20,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          HospitalDetailScreen(
                            hospital: hospital,
                          ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
