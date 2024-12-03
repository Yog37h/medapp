import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddMedicineScreen extends StatefulWidget {
  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _causeController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  DateTimeRange? _duration;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  String _medicineType = 'Tablet'; // Default value
  String _timing = 'Before Meal';
  File? _image;
  File? _prescription;
  String username = 'User';
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      setState(() {
        username = userData?['username'] ?? 'User';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickPrescription() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _prescription = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadFile(File file, String folder) async {
    try {
      String fileName = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('$folder/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _addMedicine() async {
    String name = _nameController.text.trim();
    String quantity = _quantityController.text.trim();
    String cause = _causeController.text.trim();
    String doctor = _doctorController.text.trim();
    String hospital = _hospitalController.text.trim();

    if (name.isEmpty ||
        quantity.isEmpty ||
        cause.isEmpty ||
        doctor.isEmpty ||
        hospital.isEmpty ||
        _duration == null ||
        _fromTime == null ||
        _toTime == null ||
        _image == null ||
        _prescription == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
          SnackBar(content: Text('Please fill all fields and upload files.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String today = DateTime.now().toIso8601String().split('T')[0];

      // Upload image and prescription
      String? imageUrl = await _uploadFile(_image!, 'images');
      String? prescriptionUrl = await _uploadFile(
          _prescription!, 'prescriptions');

      await FirebaseFirestore.instance.collection('medicines').add({
        'userId': user.uid,
        'name': name,
        'type': _medicineType,
        'quantity': quantity,
        'duration': {
          'from': _duration!.start.toIso8601String(),
          'to': _duration!.end.toIso8601String(),
        },
        'fromTime': _fromTime!.format(context),
        'toTime': _toTime!.format(context),
        'timing': _timing,
        'cause': cause,
        'doctor': doctor,
        'hospital': hospital,
        'date': today,
        'imageUrl': imageUrl,
        'prescriptionUrl': prescriptionUrl,
      });

      _nameController.clear();
      _quantityController.clear();
      _causeController.clear();
      _doctorController.clear();
      _hospitalController.clear();
      setState(() {
        _medicineType = 'Tablet';
        _timing = 'Before Meal';
        _image = null;
        _prescription = null;
        _duration = null;
        _fromTime = null;
        _toTime = null;
        isLoading = false;
      });

      Navigator.pop(context);
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _duration,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _duration = picked;
      });
    }
  }

  Future<void> _selectFromTime(BuildContext context) async {
    final TimeOfDay? pickedTime =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null) {
      setState(() {
        _fromTime = pickedTime;
      });
    }
  }

  Future<void> _selectToTime(BuildContext context) async {
    final TimeOfDay? pickedTime =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null) {
      setState(() {
        _toTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false, // Remove back button
        title: Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Center(
            child: Text(
              'Tell Us Your Medicines',
              style: TextStyle(fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(

              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name of Medicine',
                  labelStyle: TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _medicineType,
                items: ['Tablet', 'Tonic', 'Others'].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _medicineType = value ?? 'Tablet';
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Type of Medicine',
                  labelStyle: TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
              ),
              SizedBox(height: 15),
              if (_medicineType == 'Others') ...[
                TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Enter Details',
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
              ] else
                ...[
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _medicineType == 'Tonic'
                          ? 'Quantity in ml'
                          : 'Quantity in pills',
                      labelStyle: TextStyle(color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                ],
              SizedBox(height: 15),
              GestureDetector(
                onTap: () => _selectDateRange(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                      text: _duration == null
                          ? 'Select Duration'
                          : 'From ${_duration!.start.toLocal()} To ${_duration!
                          .end.toLocal()}',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Duration',
                      labelStyle: TextStyle(color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectFromTime(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(
                            text: _fromTime == null
                                ? 'Select From Time'
                                : 'From Time: ${_fromTime!.format(context)}',
                          ),
                          decoration: InputDecoration(
                            labelText: 'From Time',
                            labelStyle: TextStyle(color: Colors.teal),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.teal),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectToTime(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(
                            text: _toTime == null
                                ? 'Select To Time'
                                : 'To Time: ${_toTime!.format(context)}',
                          ),
                          decoration: InputDecoration(
                            labelText: 'To Time',
                            labelStyle: TextStyle(color: Colors.teal),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.teal),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _timing,
                items: ['Before Meal', 'After Meal'].map((timing) {
                  return DropdownMenuItem<String>(
                    value: timing,
                    child: Text(timing),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _timing = value ?? 'Before Meal';
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Timing',
                  labelStyle: TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _causeController,
                decoration: InputDecoration(
                  labelText: 'Cause',
                  labelStyle: TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _doctorController,
                decoration: InputDecoration(
                  labelText: 'Doctor Name',
                  labelStyle: TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _hospitalController,
                decoration: InputDecoration(
                  labelText: 'Hospital Name',
                  labelStyle: TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
              ),
    SizedBox(height: 15),
    Row(
    children: [
    // Upload Medicine Image Button
    Expanded(
    child: ElevatedButton(
    onPressed: _pickImage,
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.teal,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.symmetric(vertical: 15),
    ),
    child: Text(
    _image == null ? 'Upload Medicine Image' : 'Change Medicine Image',
    style: TextStyle(fontSize: 14), // Adjust text size for balance
    ),
    ),
    ),
    SizedBox(width: 10), // Spacing between the two buttons
    // Upload Prescription Button
    Expanded(
    child: ElevatedButton(
    onPressed: _pickPrescription,
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.teal,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.symmetric(vertical: 15),
    ),
    child: Text(
    _prescription == null ? 'Upload Prescription' : 'Change Prescription',
    style: TextStyle(fontSize: 14),
    ),
    ),
    ),
    ],
    ),

// Display selected images
    if (_image != null) ...[
    SizedBox(height: 15),
    Image.file(
    _image!,
    height: 150,
    fit: BoxFit.cover,
    ),
    SizedBox(height: 15),
    ],

    if (_prescription != null) ...[
    SizedBox(height: 15),
    Image.file(
    _prescription!,
    height: 150,
    fit: BoxFit.cover,
    ),
    SizedBox(height: 15),
    ],

    SizedBox(height: 25), // Space before "Add Medicine" button

// Add Medicine Button
    isLoading
    ? Center(child: CircularProgressIndicator())
        : ElevatedButton(
    onPressed: _addMedicine,
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.teal,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    elevation: 4, // Slight shadow for elegance
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(Icons.add, size: 20, color: Colors.white),
    SizedBox(width: 8),
    Text(
    'Add Medicine',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    ],
    ),
    ),

  ]),
    )));
  }
}
