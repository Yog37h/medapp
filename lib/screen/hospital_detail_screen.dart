// lib/screens/hospital_detail_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../model/hospital_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalDetailScreen extends StatefulWidget {
  final Hospital hospital;


  HospitalDetailScreen({
    required this.hospital,
  });

  @override
  _HospitalDetailScreenState createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen> {
  String? _username;
  List<String> domains = [
    "Cardiology",
    "ENT",
    "Pediatrics",
    "Eye",
    "Dermatology"
  ];

  Map<String, List<String>> domainDoctors = {};

  String? selectedDomain;
  String? selectedSlot;
  DateTime? visitDate;
  String? selectedDoctor;
  String? consultID;

  List<String> timings = [];
  List<String> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    timings = _generateRandomTimings();
    _loadDomainDoctors();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _username = userDoc['username']; // Adjust this based on your Firestore structure
      });
    }
  }

  void _loadDomainDoctors() {
    domainDoctors = widget.hospital.domainDoctors;
    filteredDoctors = domainDoctors['Cardiology'] ?? [];
  }

  List<String> _generateRandomTimings() {
    Random random = Random();
    return List.generate(15, (index) {
      int startHour = random.nextInt(12) + 1;
      int endHour = random.nextInt(12) + 1;
      String periodStart = startHour >= 12 ? "PM" : "AM";
      String periodEnd = endHour >= 12 ? "PM" : "AM";
      return "$startHour:00 $periodStart - $endHour:00 $periodEnd";
    });
  }

  void _bookAppointment() {
    Random random = Random();
    selectedDoctor = filteredDoctors[random.nextInt(filteredDoctors.length)];
    consultID = "CONSULT-${random.nextInt(999999)}";
    if (visitDate != null && selectedSlot != null) {
      if (selectedSlot!.contains("AM") && selectedSlot!.startsWith("12")) {
        visitDate = visitDate!.add(Duration(days: 1));
      }
    }
    setState(() {});
  }

  Future<void> _storeAppointmentDetails() async {
    final user = FirebaseAuth.instance.currentUser; // Fetch the user here again
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated.')),
      );
      return;
    }

    CollectionReference appointmentCollection = FirebaseFirestore.instance.collection('appointmentdetails');

    try {
      await appointmentCollection.add({
        'domain': selectedDomain,
        'date': visitDate,
        'slot': selectedSlot,
        'doctor': selectedDoctor,
        'consultID': consultID,
        'userID': user.uid, // Now we have the user ID
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment details stored successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error storing appointment: $e')),
      );
    }
  }

  void _confirmBooking() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Booking Confirmed!"),
          content: Text("Your appointment has been confirmed."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _storeAppointmentDetails(); // Store appointment details
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _cancelBooking() {
    setState(() {
      selectedDomain = null;
      selectedSlot = null;
      visitDate = null;
      selectedDoctor = null;
      consultID = null;
    });
  }

  void _selectDate() async {
    DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selected != null && selected != visitDate) {
      setState(() {
        visitDate = selected;
      });
    }
  }

  void _viewLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Hospital Location"),
          ),
          body: FlutterMap(
            options: MapOptions(
              center: LatLng(widget.hospital.latitude, widget.hospital.longitude),
              zoom: 13.0,
            ),
            nonRotatedChildren: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                backgroundColor: Colors.transparent,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(widget.hospital.latitude, widget.hospital.longitude),
                    builder: (ctx) => Container(
                      child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String rating = "4.${Random().nextInt(5)}";
    List<String> reviews = widget.hospital.reviews;

    LatLng hospitalLocation = LatLng(widget.hospital.latitude, widget.hospital.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.hospital.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Domain Selection
            Text(
              "Select Domain",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedDomain,
              hint: Text("Select a Domain"),
              isExpanded: true,
              underline: Container(
                height: 2,
                color: Colors.teal,
              ),
              items: domains.map((String domain) {
                return DropdownMenuItem<String>(
                  value: domain,
                  child: Text(domain),
                );
              }).toList(),
              onChanged: (String? newDomain) {
                setState(() {
                  selectedDomain = newDomain;
                  timings = _generateRandomTimings();
                  filteredDoctors = domainDoctors[newDomain!] ?? [];
                });
              },
            ),
            SizedBox(height: 16),
            if (selectedDomain != null)
              Text(
                "Selected Domain: $selectedDomain",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            SizedBox(height: 16),

            // Date Selection
            Text(
              "Select Date",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _selectDate,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text("Pick a Date"),
            ),
            SizedBox(height: 8),
            if (visitDate != null)
              Text(
                "Selected Date: ${DateFormat('yyyy-MM-dd').format(visitDate!)}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            SizedBox(height: 16),

            // Available Slots
            Text(
              "Available Slots",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: timings.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSlot = timings[index];
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: selectedSlot == timings[index] ? Colors.teal : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          timings[index],
                          style: TextStyle(
                            color: selectedSlot == timings[index] ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            if (selectedSlot != null)
              Text(
                "Selected Slot: $selectedSlot",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            SizedBox(height: 16),

            // Famous Doctors
            if (selectedDomain != null)
              Text(
                "Famous Doctors in $selectedDomain",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 8),
            Container(
              height: 100,
              child: ListView.builder(
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredDoctors[index]),
                    onTap: () {
                      setState(() {
                        selectedDoctor = filteredDoctors[index];
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            if (selectedDoctor != null)
              Text(
                "Selected Doctor: $selectedDoctor",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            SizedBox(height: 16),

            // Booking Button and Details
            if (selectedDomain != null && visitDate != null && selectedSlot != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: _bookAppointment,
                    child: Text("Book Appointment"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                  if (consultID != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Text(
                          "Booking Details",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text("Domain: $selectedDomain"),
                        Text("Date: ${DateFormat('yyyy-MM-dd').format(visitDate!)}"),
                        Text("Slot: $selectedSlot"),
                        Text("Doctor: $selectedDoctor"),
                        Text("Consult ID: $consultID"),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _confirmBooking,
                              child: Text("Confirm Booking"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _cancelBooking,
                              child: Text("Cancel Booking"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            SizedBox(height: 16),

            // Reviews Section
            Text(
              "Reviews",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reviews.map((review) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "• $review",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // View Location Button
            ElevatedButton(
              onPressed: _viewLocation,
              child: Text("View Location"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }}
