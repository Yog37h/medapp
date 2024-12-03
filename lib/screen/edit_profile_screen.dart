import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final String userId;

  EditProfileScreen(this.userId);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final picker = ImagePicker();
  File? _imageFile;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _relationController = TextEditingController();
  final _newPhoneNumberController = TextEditingController();
  String? _selectedBloodGroup;
  String? _selectedGender;
  DateTime? _dob;
  int? _age;
  String? _photoURL; // Store the user's photo URL
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('newdata').doc(widget.userId).get();
        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>;
          _nameController.text = data['username'] ?? '';
          _emailController.text = data['email'] ?? '';
          _dobController.text = data['dob'] ?? '';
          _relationController.text = data['relationship'] ?? 'Self';
          _newPhoneNumberController.text = data['phoneNumber'] ?? '';
          _selectedBloodGroup = data['bloodGroup'] ?? 'Not specified';
          _selectedGender = data['gender'] ?? 'Not specified';
          _photoURL = data['photoURL']; // Retrieve photo URL

          if (data['dob'] != null && data['dob'].isNotEmpty) {
            _dob = DateTime.tryParse(data['dob']);
            _age = _calculateAge(_dob);
          }

          setState(() {}); // Update the UI with fetched data
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile != null) {
      try {
        // Create a reference to the storage location
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        // Upload the image
        await storageRef.putFile(_imageFile!);

        // Get the download URL
        String downloadURL = await storageRef.getDownloadURL();
        print("Image uploaded successfully. URL: $downloadURL");
        return downloadURL; // Return the URL
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
    return null; // Return null if no image is selected
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        // Upload image and get URL
        String? imageUrl = await _uploadImage();

        await FirebaseFirestore.instance.collection('newdata').doc(userId).set({
          'username': _nameController.text,
          'email': _emailController.text,
          'dob': _dobController.text,
          'relationship': _relationController.text,
          'bloodGroup': _selectedBloodGroup,
          'gender': _selectedGender,
          'phoneNumber': _newPhoneNumberController.text,
          'age': _age,
          'photoURL': imageUrl ?? _photoURL, // Save the new URL or retain old one
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      }
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _dob) {
      setState(() {
        _dob = pickedDate;
        _dobController.text = _formatDate(pickedDate);
        _age = _calculateAge(pickedDate);
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Widget _buildBloodGroupSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Blood Group', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: [
            for (var group in ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Other'])
              ChoiceChip(
                label: Text(group),
                selected: _selectedBloodGroup == group,
                onSelected: (selected) {
                  setState(() {
                    _selectedBloodGroup = selected ? group : null;
                  });
                },
              ),
          ],
        ),
        if (_selectedBloodGroup == 'Other')
          TextField(
            decoration: InputDecoration(labelText: 'Enter Blood Group'),
            onChanged: (value) {
              setState(() {
                _selectedBloodGroup = value;
              });
            },
          ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: [
            for (var gender in ['Male', 'Female', 'Not Disclosed'])
              ChoiceChip(
                label: Text(gender),
                selected: _selectedGender == gender,
                onSelected: (selected) {
                  setState(() {
                    _selectedGender = selected ? gender : null;
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _ageField() {
    return Container(
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blueAccent.withOpacity(0.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Age', style: TextStyle(fontSize: 16)),
          Text(_age != null ? '$_age years' : 'Not specified', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!) as ImageProvider
                      : _photoURL != null ? NetworkImage(_photoURL!) : NetworkImage('https://via.placeholder.com/150'),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _newPhoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _relationController,
                decoration: InputDecoration(labelText: 'Relationship'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDateOfBirth,
              ),
              _ageField(),
              SizedBox(height: 16),
              _buildBloodGroupSelection(),
              SizedBox(height: 16),
              _buildGenderSelection(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
