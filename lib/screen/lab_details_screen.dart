import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/model/lab_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart'; // Use latlong2 for LatLng
import 'package:flutter_map/flutter_map.dart'; // Flutter map package
import 'package:intl/intl.dart'; // For formatting the date and time
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LabDetailsScreen extends StatefulWidget {
  final Lab lab;

  LabDetailsScreen({required this.lab});

  @override
  _LabDetailsScreenState createState() => _LabDetailsScreenState();
}

class _LabDetailsScreenState extends State<LabDetailsScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTimeFrom;
  TimeOfDay? _selectedTimeTo;
  LatLng? _selectedLocation;
  DateTime? _selectedBookingDate;
  TimeOfDay? _selectedBookingTime;
  String? _selectedAvailabilitySlot;
  String? _username; // For storing the fetched username
  String? _generatedId; // For storing the generated ID

// Function to fetch username from Firebase
  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _username = userDoc['username']; // Adjust this based on your Firestore structure
      });
    }
  }

// Function to show availability slots dialog
  Future<void> _showAvailabilityDialog(BuildContext context) async {
    await _fetchUsername(); // Fetch username before showing the dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(""
              "Select Availability"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date Picker for selecting booking date
              ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.teal),
                title: Text(
                  _selectedBookingDate == null
                      ? 'Select Booking Date'
                      : DateFormat.yMMMd().format(_selectedBookingDate!),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedBookingDate = pickedDate;
                    });
                  }
                },
              ),
              // Time slot selection (You can customize the time slots as needed)
              DropdownButton<String>(
                hint: Text('Select Time Slot'),
                value: _selectedAvailabilitySlot,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAvailabilitySlot = newValue;
                  });
                },
                items: <String>['9:00 AM', '10:00 AM', '11:00 AM', '1:00 PM', '2:00 PM']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Generate a unique ID for the booking
                _generatedId = _generateUniqueId();
                // Update the dialog to show the generated ID
                Navigator.of(context).pop(); // Close availability dialog
                _showConfirmationDialogs(context); // Show confirmation dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              child: Text('Generate ID'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent,
              ),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

// Function to show confirmation dialog with booking details
  Future<void> _showConfirmationDialogs(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text("Confirm Booking"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Generated ID: ${_generatedId ?? 'Not generated'}"),
                Text("Date: ${_selectedBookingDate != null ? DateFormat.yMMMd().format(_selectedBookingDate!) : 'Not selected'}"),
                Text("Time Slot: ${_selectedAvailabilitySlot ?? 'Not selected'}"),
                Text("Username: ${_username ?? 'Loading...'}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _saveBookingToFirebase();
                Navigator.of(context).pop(); // Close confirmation dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Go back to re-enter the data
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orangeAccent,
              ),
              child: Text('Cancel & Go Back'),
            ),
          ],
        );
      },
    );
  }

// Function to save booking details to Firebase
  Future<void> _saveBookingToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _selectedBookingDate != null && _selectedAvailabilitySlot != null) {
      // Create a map to hold relevant lab data
      final labData = {
        'name': widget.lab.name,
        'domain': widget.lab.domain,
        'about': widget.lab.about,
        'faqs': widget.lab.faqs, // Make sure this is in a serializable format
        'benefits': widget.lab.benefits,
        // If you need to store the icon, consider storing its properties or using a string representation.
        // For example, if you want to store the icon's name or description:
        // 'icon': widget.lab.icon.toString(), // Adjust this based on your needs
      };

      await FirebaseFirestore.instance.collection('visitlab').add({
        'userId': user.uid,
        'username': _username,
        'lab': labData, // Save lab as a map
        'date': _selectedBookingDate,
        'timeSlot': _selectedAvailabilitySlot,
        'generatedId': _generatedId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show a Snackbar or a confirmation dialog to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking confirmed successfully!')),
      );

      // Reset fields after successful booking
      setState(() {
        _selectedBookingDate = null;
        _selectedAvailabilitySlot = null;
        _generatedId = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields.')),
      );
    }
  }


// Function to generate a unique ID (for demonstration purposes)
  String _generateUniqueId() {
    // You can implement a more sophisticated unique ID generator
    return 'ID-${DateTime.now().millisecondsSinceEpoch}';
  }



  // Function to handle location permissions
  Future<bool> _handleLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      return true;
    } else if (status.isDenied || status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return false;
  }


  // Function to pick the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Function to pick the time
  Future<void> _selectTime(BuildContext context, bool isFrom) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isFrom) {
          _selectedTimeFrom = pickedTime;
        } else {
          _selectedTimeTo = pickedTime;
        }
      });
    }
  }

  // Function to show map and let the user pick a location
  Future<void> _selectLocation(BuildContext context) async {
    if (await _handleLocationPermission()) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      // Open a map widget to let the user pick a location
      await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 400,
            child: FlutterMap(
              options: MapOptions(
                center: _selectedLocation,
                zoom: 14,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedLocation = point; // Update location on tap
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
                        builder: (context) =>
                            Icon(
                              Icons.location_on,
                              size: 50.0,
                              color: Colors.red,
                            ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permission denied.")),
      );
    }
  }

  // Function to display the dialog for homecheck details
  Future<void> _showHomecheckDialog(BuildContext context) async {
    // Resetting inputs for a new home checkup
    _selectedDate = null;
    _selectedTimeFrom = null;
    _selectedTimeTo = null;
    _selectedLocation = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Homecheck Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date Picker with icon
                ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.teal),
                  title: Text(
                    _selectedDate == null
                        ? 'Fix the Date'
                        : DateFormat.yMMMd().format(_selectedDate!),
                  ),
                  onTap: () => _selectDate(context),
                ),
                // Time Picker From with icon
                ListTile(
                  leading: Icon(Icons.access_time_filled, color: Colors.teal),
                  title: Text(
                    _selectedTimeFrom == null
                        ? 'Fix Start Time'
                        : _selectedTimeFrom!.format(context),
                  ),
                  onTap: () => _selectTime(context, true),
                ),
                // Time Picker To with icon
                ListTile(
                  leading: Icon(Icons.access_time, color: Colors.teal),
                  title: Text(
                    _selectedTimeTo == null
                        ? 'Fix End Time'
                        : _selectedTimeTo!.format(context),
                  ),
                  onTap: () => _selectTime(context, false),
                ),
                // Location Picker with icon
                ListTile(
                  leading: Icon(Icons.location_on, color: Colors.teal),
                  title: Text(
                    _selectedLocation == null
                        ? 'Fix Select Location'
                        : 'Location: ${_selectedLocation!
                        .latitude}, ${_selectedLocation!.longitude}',
                  ),
                  onTap: () => _selectLocation(context),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _saveToFirebase();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.green,
              ),
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog for re-entering
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent,
              ),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to save details to Firebase and show confirmation
  Future<void> _saveToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _selectedDate != null && _selectedLocation != null) {
      await FirebaseFirestore.instance.collection('laborders').add({
        'userId': user.uid,
        'lab': widget.lab.name,
        'domain': widget.lab.domain,
        'date': _selectedDate,
        'timeFrom': _selectedTimeFrom?.format(context),
        'timeTo': _selectedTimeTo?.format(context),
        'location': {
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
        },
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show confirmation with a pop-up dialog
      _showConfirmationDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields.')),
      );
    }
  }

  // Function to display the confirmation pop-up
  Future<void> _showConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Confirm Homecheck Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Date: ${DateFormat.yMMMd().format(_selectedDate!)}"),
                Text("Start Time: ${_selectedTimeFrom?.format(context)}"),
                Text("End Time: ${_selectedTimeTo?.format(context)}"),
                Text(
                    "Location: "
                        "${_selectedLocation!
                        .latitude}, ${_selectedLocation!.longitude}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.green,
              ),
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Go back to re-enter the data
                _showHomecheckDialog(context); // Reopen the dialog for edits
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orangeAccent,
              ),
              child: Text('Cancel & Go Back'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lab.name),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Added for scrollable content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.lab.domain,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showHomecheckDialog(context); // Handle 'Homecheck'
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text('Homecheck'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showAvailabilityDialog(context);
                      // Implement your booking logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text('Book'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'About this Test:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                widget.lab.about,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Benefits:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...widget.lab.benefits.map((benefit) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text('• $benefit', style: TextStyle(fontSize: 14)),
                  )),
              SizedBox(height: 16),
              Text(
                'FAQs:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...widget.lab.faqs.map((faq) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text('• $faq', style: TextStyle(fontSize: 14)),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}