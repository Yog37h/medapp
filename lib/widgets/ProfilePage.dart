import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_to_do_list/screen/edit_profile_screen.dart';
import 'package:flutter_to_do_list/screen/PrescriptionScreen.dart';
import 'package:flutter_to_do_list/screen/profile_view_screen.dart';
import 'package:flutter_to_do_list/screen/ReportsScreen.dart';
import 'package:flutter_to_do_list/screen/orders_placed_screen.dart';
import 'package:flutter_to_do_list/screen/lab_tests_screen.dart';
import 'package:flutter_to_do_list/screen/appointments_screen.dart';
import 'package:flutter_to_do_list/screen/activity_screen.dart';

class ProfilePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>?> getUserData() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('newdata')
        .doc(user?.uid)
        .get();
    return userData.data() as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No data found'));
        }

        final userData = snapshot.data!;
        final String username = userData['username'] ?? 'User';
        final String phoneNumber = userData['phoneNumber'] ?? '0000000000';
        final String photoURL = userData['photoURL'] ??
            'https://via.placeholder.com/150';
        final String lastTwoDigits = phoneNumber.substring(phoneNumber.length - 2);
        final String userId = user?.uid ?? '';

        return Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
            centerTitle: true,
            backgroundColor: Colors.teal,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(photoURL),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome, $username',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: $username',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ID: EZMED_${username.substring(0, 3).toUpperCase()}$lastTwoDigits',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProfileButton(context, 'Edit Profile', Icons.edit, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(userId),
                        ),
                      );
                    }),
                    _buildProfileButton(context, 'View Profile', Icons.visibility, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileViewScreen(userId),
                        ),
                      );// Add View Profile functionality
                    }),
                  ],
                ),
                SizedBox(height: 20),
                _buildActionRow(context, 'Prescription', Icons.receipt_long, onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PrescriptionScreen(),
                    ),
                  );
                }),
                _buildActionRow(context, 'Reports', Icons.assignment, onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReportsScreen(),
                    ),
                  );
                }),
                _buildFullWidthButton(context, 'Orders Placed', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OrdersPlacedScreen(),
                    ),
                  );
                }),
                _buildFullWidthButton(context, 'Lab Tests', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LabTestsScreen(),
                    ),
                  );
                }),
                _buildFullWidthButton(context, 'Appointments', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AppointmentsScreen(),
                    ),
                  );
                }),
                _buildFullWidthButton(context, 'Activity', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ActivityScreen(),
                    ),
                  );
                }),
                SizedBox(height: 30),
                _buildLogoutButton(context, 'Logout'),
                SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileButton(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onTap,
    );
  }

  Widget _buildActionRow(
      BuildContext context, String title, IconData icon, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: Icon(icon, color: Colors.teal),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthButton(
      BuildContext context, String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onTap,
        child: Text(
          title,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pop();
        },
        child: Text(
          title,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
