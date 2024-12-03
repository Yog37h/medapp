import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/model/doctor_model.dart';
import 'package:flutter_to_do_list/screen/admin_panel_screen.dart';
import 'package:flutter_to_do_list/screen/medicines_screen.dart';
import 'package:flutter_to_do_list/screen/cart_screen.dart';
import 'package:flutter_to_do_list/screen/consult_us_screen.dart';
import 'package:flutter_to_do_list/screen/lab_test_screen.dart';
import 'package:flutter_to_do_list/screen/doctor_specialist_screen.dart';
import 'package:flutter_to_do_list/screen/calorie_counter_screen.dart';

import 'package:animated_text_kit/animated_text_kit.dart';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_to_do_list/screen/NotificationsScreen.dart';


// Importing data files for each domain
import '../data/orthopaedics_data.dart';
import '../data/ent_data.dart';
import '../data/paediatrics_data.dart';
import '../data/cardiology_data.dart';
import '../data/dermatology_data.dart';
import '../data/urology_data.dart';
import '../data/gynaecology_data.dart';
import '../data/general_physician_data.dart';


import '../screen/steps_counter_screen.dart';
import '../screen/calorie_counter_screen.dart';
import '../screen/track_sugar_screen.dart';
import '../screen/know_your_food_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "";

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  void _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        username = snapshot['username'] ?? "User";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_hospital, size: 30, color: Colors.teal),
                      SizedBox(width: 8),
                      Text("Hi $username",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications, color: Colors.teal),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => NotificationsScreen()),
                          );
                        },
                      ),

                      IconButton(
                        icon: Icon(Icons.admin_panel_settings, color: Colors.teal),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => AdminPanelScreen()),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.shopping_cart, color: Colors.teal),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => CartScreen()),
                          );
                        },
                      ),
                    ],
                  )

                ],
              ),

              SizedBox(height: 24),
              // Animated Intro Below the Welcome Message
              Center(
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Welcome to ",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: [
                        TyperAnimatedText(
                          'Ezmed',
                          textStyle: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                          speed: Duration(milliseconds: 100), // Speed of typing
                        ),
                        TyperAnimatedText(
                          'எஸ்மெட்', // Tamil
                          textStyle: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                          speed: Duration(milliseconds: 100),
                        ),
                        TyperAnimatedText(
                          'എസ്എമഡ്', // Malayalam
                          textStyle: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                          speed: Duration(milliseconds: 100),
                        ),
                        TyperAnimatedText(
                          'ఎజ్మెడ్', // Telugu
                          textStyle: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                          speed: Duration(milliseconds: 100),
                        ),
                        TyperAnimatedText(
                          'ಎಜ್ಮೆಡ್', // Kannada
                          textStyle: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                          speed: Duration(milliseconds: 100),
                        ),
                      ],
                      onTap: () {
                        print("Tap Event"); // Optional tap event
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFeatureItem("Get Medicines", Icons.local_pharmacy, MedicinesScreen()),
                  _buildFeatureItem("Consult Us", Icons.medical_services, ConsultUsScreen()),
                  _buildFeatureItem("Book Lab Test", Icons.science, LabTestScreen()),
                ],
              ),
              SizedBox(height: 24),
              _buildDoctorSpecialists(),
              SizedBox(height: 24),
              _buildHealthTools(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFeatureItem(String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.teal[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSpecialists() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Top Doctor Specialists", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 16,
            childAspectRatio: 3 / 2,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildDoctorSpecialistItem("Orthopaedics", Icons.healing, orthopaedicsDoctors),
              _buildDoctorSpecialistItem("ENT", Icons.hearing, entDoctors),
              _buildDoctorSpecialistItem("Paediatrics", Icons.child_friendly, paediatricsDoctors),
              _buildDoctorSpecialistItem("Cardiology", Icons.favorite, cardiologyDoctors),
              _buildDoctorSpecialistItem("Dermatology", Icons.local_hospital, dermatologyDoctors),
              _buildDoctorSpecialistItem("Urology", Icons.water_damage, urologyDoctors),
              _buildDoctorSpecialistItem("Gynaecology", Icons.pregnant_woman, gynaecologyDoctors),
              _buildDoctorSpecialistItem("General Physician", Icons.person, generalPhysicianDoctors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorSpecialistItem(String title, IconData icon, List<Doctor> doctors) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => DoctorSpecialistScreen(title: title, doctors: doctors)),
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 35, color: Colors.white),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Health Tools", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3 / 2,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildHealthToolItem("Glucose Predict", Icons.directions_walk, GlucoseMonitoringScreen()),
            _buildHealthToolItem("Calorie Counter", Icons.fastfood, CalorieCounterScreen()),
            _buildHealthToolItem("Track Sugar", Icons.bloodtype, TrackSugarScreen()),
            _buildHealthToolItem("Know Your Health", Icons.local_dining, KnowYourFoodScreen()),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthToolItem(String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.teal[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 38, color: Colors.white),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
