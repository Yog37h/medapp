import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/data/lab_data.dart'; // Import your lab data file
import 'package:flutter_to_do_list/screen/lab_details_screen.dart';
import 'package:flutter_to_do_list/screen/lab_details_screen.dart'; // Import the LabDetailsScreen

class LabTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Lab Test'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: labList.length, // Fetches the number of labs in your list
        itemBuilder: (context, index) {
          final lab = labList[index]; // Get the current lab from the list
          return Card(
            margin: EdgeInsets.all(10),
            elevation: 4,
            child: ListTile(
              leading: lab.icon, // Display the lab's icon on the left
              title: Text(
                lab.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(lab.domain),
              onTap: () {
                // When a lab is tapped, navigate to lab details screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LabDetailsScreen(lab: lab), // Pass the current lab to LabDetailsScreen
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
