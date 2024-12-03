import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/model/doctor_model.dart';
import 'doctor_detail_screen.dart';

class DoctorSpecialistScreen extends StatelessWidget {
  final String title;
  final List<Doctor> doctors;

  DoctorSpecialistScreen({required this.title, required this.doctors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal, // Matching the teal theme
        elevation: 4, // Adds a slight shadow to the AppBar for a professional look
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4, // Adds elevation to the card for a polished look
              margin: EdgeInsets.symmetric(vertical: 10), // Space between cards
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(doctor.imagePath),
                  backgroundColor: Colors
                      .grey[200], // Background color in case image fails to load
                ),
                title: Text(
                  doctor.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Matching the theme color
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      doctor.region,
                      style: TextStyle(color: Colors
                          .grey[600]), // Subtle gray for the region
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        SizedBox(width: 4),
                        Text(
                          '${doctor.rating}/5',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.teal, // Adds teal color to trailing icon
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DoctorDetailScreen(doctor: doctor),
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
