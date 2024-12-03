import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/model/doctor_model.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor;

  DoctorDetailScreen({required this.doctor});

  @override
  _DoctorDetailScreenState createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  final String registrationId = 'DOC${Random().nextInt(900000) + 100000}';
  String username = ''; // To store the current user's name

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  // Fetching the username from Firebase Firestore
  Future<void> fetchUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          username = snapshot.get('username') ?? 'User';
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.doctor.name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 4, // Slight shadow for AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(widget.doctor.imagePath),
                backgroundColor: Colors.grey[200], // Placeholder for image
              ),
            ),
            SizedBox(height: 20),

            // Doctor's Name
            Text(
              'Name: ${widget.doctor.name}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 12),

            // Registration ID
            Text(
              'Registration ID: $registrationId',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),

            // Doctor's Region
            Text(
              'Region: ${widget.doctor.region}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),

            // Rating with star icon
            Row(
              children: [
                Text(
                  'Rating: ${widget.doctor.rating}/5',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.star, color: Colors.amber, size: 20),
              ],
            ),
            SizedBox(height: 16),

            // Experience
            Text(
              'Experience: ${widget.doctor.experience}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),

            // Past Works
            Text(
              'Past Works: ${widget.doctor.pastWorks}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),

            // Awards
            Text(
              'Awards: ${widget.doctor.awards}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),

            // Visiting Hours
            Text(
              'Visiting Hours: ${widget.doctor.visitingHours}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                // Digital Consult Button
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.video_call, color: Colors.white),
                    label: Text('Digital Consult'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5, // Adds slight shadow for elegance
                    ),
                    onPressed: () => _showConsultationOptions(context),
                  ),
                ),
                SizedBox(width: 16), // Space between buttons

                // Call to Book Button
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.phone, color: Colors.white),
                    label: Text('Call to Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5, // Adds slight shadow for elegance
                    ),
                    onPressed: _callToBook,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  void _showConsultationOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime initialDate = DateTime.now().add(Duration(days: 3));
        DateTime selectedDate = initialDate;
        String selectedTimeSlot = '11:00 AM';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            List<String> _generateTimeSlots() {
              List<String> slots = [];
              DateTime startTime = DateTime(initialDate.year, initialDate.month, initialDate.day, 11, 0);
              for (int i = 0; i < 12; i++) {
                slots.add(DateFormat('h:mm a').format(startTime.add(Duration(minutes: i * 10))));
              }
              return slots;
            }

            return AlertDialog(
              title: Text('Select Consultation Slot'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<DateTime>(
                    value: selectedDate,
                    items: List.generate(3, (index) {
                      DateTime dateOption = initialDate.add(Duration(days: index));
                      return DropdownMenuItem(
                        value: dateOption,
                        child: Text(DateFormat('EEE, MMM d').format(dateOption)),
                      );
                    }),
                    onChanged: (DateTime? value) {
                      setState(() {
                        selectedDate = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedTimeSlot,
                    items: _generateTimeSlots().map((String slot) {
                      return DropdownMenuItem<String>(
                        value: slot,
                        child: Text(slot),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedTimeSlot = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                ElevatedButton.icon(
                  icon: Icon(Icons.check_circle),
                  label: Text('Confirm Slot'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _confirmConsultationSlot(context, selectedDate, selectedTimeSlot);
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.cancel),
                  label: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmConsultationSlot(BuildContext context, DateTime date, String timeSlot) async {
    String formattedDate = DateFormat('EEE, MMM d').format(date);
    String message = 'Your consultation slot is confirmed for $formattedDate at $timeSlot.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    // Generate Google Meet link (placeholder)
    String googleMeetLink = await _generateGoogleMeetLink(date, timeSlot);

    // Send details via Twilio to WhatsApp
    String whatsappMessage = 'Patient: $username\nDoctor: ${widget.doctor.name}\nDate: $formattedDate\nTime: $timeSlot\nRegistration ID: $registrationId\nGoogle Meet Link: $googleMeetLink';
    _sendWhatsAppMessage(whatsappMessage, false);

    // Send confirmation message to another WhatsApp number
    _sendWhatsAppMessage(whatsappMessage, true);
  }

  void _callToBook() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '6380102330');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _sendWhatsAppMessage(String message, bool isConfirmation) async {
    final String accountSid = 'AC28b64839b2103651c36b132e4735574b';
    final String authToken = '707d232a4f216d470daa842ef508490e';
    final String fromWhatsAppNumber = 'whatsapp:+14155238886';
    final String toWhatsAppNumber = isConfirmation ? 'whatsapp:+917200680238' : 'whatsapp:+916380102330';

    final String url = 'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
      },
      body: {
        'From': fromWhatsAppNumber,
        'To': toWhatsAppNumber,
        'Body': message,
      },
    );

    if (response.statusCode == 201) {
      print('WhatsApp message sent successfully.');
    } else {
      print('Failed to send WhatsApp message: ${response.body}');
    }
  }

  Future<String> _generateGoogleMeetLink(DateTime date, String timeSlot) async {
    // Placeholder for Google Meet link generation
    // Replace with actual Google Calendar API integration
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    String formattedTime = DateFormat('HH:mm').format(DateFormat('h:mm a').parse(timeSlot));
    return 'https://meet.google.com/new?authuser=0&hs=122&pli=1&ictx=2&show=0&start=$formattedDate-T$formattedTime:00Z';
  }
}
