import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_to_do_list/screen/add_medicines_screen.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String username = 'User';
  Set<String> _checkedMedicines = {}; // To keep track of checked medicines

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

  Future<void> _toggleMedicine(String medicineId, bool isChecked) async {
    if (isChecked) {
      // Move medicine to consumed today section
      await FirebaseFirestore.instance.collection('medicines').doc(medicineId).update({
        'consumedToday': true,
      });
      setState(() {
        _checkedMedicines.add(medicineId);
      });
    } else {
      // Remove medicine from consumed today section
      await FirebaseFirestore.instance.collection('medicines').doc(medicineId).update({
        'consumedToday': false,
      });
      setState(() {
        _checkedMedicines.remove(medicineId);
      });
    }
  }

  Future<void> _removeMedicine(String medicineId) async {
    // Delete the medicine from the database
    await FirebaseFirestore.instance.collection('medicines').doc(medicineId).delete();
    setState(() {
      // Ensure the medicine is also removed from the checked list if it exists there
      _checkedMedicines.remove(medicineId);
    });
  }

  Future<void> _showMedicineDetails(String medicineId) async {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('medicines').doc(medicineId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text('Loading...'),
                content: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return AlertDialog(
                title: Text('Not Found'),
                content: Text('The requested medicine could not be found.'),
              );
            }

            final medicine = snapshot.data!.data() as Map<String, dynamic>;
            final name = medicine['name'] ?? 'No Name';
            final type = medicine['type'] ?? 'No Type';
            final quantity = medicine['quantity'] ?? 'No Quantity';
            final fromDate = _getDate(medicine['duration']['from']) ?? DateTime.now();
            final toDate = _getDate(medicine['duration']['to']) ?? DateTime.now();
            final fromTime = medicine['fromTime'] ?? 'No From Time';
            final toTime = medicine['toTime'] ?? 'No To Time';
            final timing = medicine['timing'] ?? 'No Timing';
            final cause = medicine['cause'] ?? 'No Cause';
            final doctor = medicine['doctor'] ?? 'No Doctor';
            final hospital = medicine['hospital'] ?? 'No Hospital';
            final imageUrl = medicine['imageUrl'];
            final prescriptionUrl = medicine['prescriptionUrl'];

            return AlertDialog(
              title: Text('Medicine Details'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      Image.network(imageUrl),
                    if (prescriptionUrl != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),

                      ),
                    Text('Name: $name'),
                    Text('Type: $type'),
                    Text('Quantity: $quantity'),
                    Text('Duration: From ${fromDate.toLocal()} To ${toDate.toLocal()}'),
                    Text('Time: $fromTime - $toTime'),
                    Text('Timing: $timing'),
                    Text('Cause: $cause'),
                    Text('Doctor: $doctor'),
                    Text('Hospital: $hospital'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Close'),
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

  DateTime? _getDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        // Handle parsing error if the string is not in the correct format
        return null;
      }
    }
    return null;
  }

  Future<void> _showAllMedicines() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('All Medicines'),
          content: Container(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('medicines')
                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No medicines found.'));
                }

                final medicines = snapshot.data!.docs;

                return ListView(
                  children: medicines.map((doc) {
                    final medicine = doc.data() as Map<String, dynamic>;
                    final id = doc.id;
                    final name = medicine['name'] ?? 'No Name';

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _removeMedicine(id);
                            Navigator.of(context).pop(); // Close the dialog after removing the medicine
                          },
                        ),
                        onTap: () {
                          _showMedicineDetails(id);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        title: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Center(
            child: Text(
              '          My Medicines',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddMedicineScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Hello, $username!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _showAllMedicines,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal.shade700,
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'View All Medicines',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('medicines')
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.teal,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No medicines found.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  final medicines = snapshot.data!.docs;
                  final today = DateTime.now();
                  final todayStart = DateTime(today.year, today.month, today.day);
                  final todayEnd = todayStart.add(Duration(days: 1));

                  final medicinesToBeConsumedToday = medicines.where((doc) {
                    final medicine = doc.data() as Map<String, dynamic>;
                    final from = _getDate(medicine['duration']['from']) ?? DateTime.now();
                    final to = _getDate(medicine['duration']['to']) ?? DateTime.now();
                    return from.isBefore(todayEnd) &&
                        to.isAfter(todayStart) &&
                        (medicine['consumedToday'] ?? false) == false;
                  }).toList();

                  final consumedMedicines = medicines.where((doc) {
                    final medicine = doc.data() as Map<String, dynamic>;
                    final from = _getDate(medicine['duration']['from']) ?? DateTime.now();
                    final to = _getDate(medicine['duration']['to']) ?? DateTime.now();
                    return from.isBefore(todayEnd) &&
                        to.isAfter(todayStart) &&
                        (medicine['consumedToday'] ?? false) == true;
                  }).toList();

                  final missedMedicines = medicines.where((doc) {
                    final medicine = doc.data() as Map<String, dynamic>;
                    final from = _getDate(medicine['duration']['from']) ?? DateTime.now();
                    final to = _getDate(medicine['duration']['to']) ?? DateTime.now();
                    final fromTime = DateTime.tryParse(
                        '${today.toIso8601String().split('T')[0]} ${medicine['fromTime'] ?? '00:00'}');
                    final toTime = DateTime.tryParse(
                        '${today.toIso8601String().split('T')[0]} ${medicine['toTime'] ?? '23:59'}');
                    final isNotChecked = !_checkedMedicines.contains(doc.id);
                    return from.isBefore(todayEnd) &&
                        to.isAfter(todayStart) &&
                        isNotChecked &&
                        today.isAfter(fromTime ?? DateTime.now()) &&
                        today.isBefore(toTime ?? DateTime.now());
                  }).toList();

                  return ListView(
                    children: [
                      if (medicinesToBeConsumedToday.isNotEmpty)
                        buildMedicineSection(
                            'Medicines to be Consumed Today', medicinesToBeConsumedToday, true),
                      if (consumedMedicines.isNotEmpty)
                        buildMedicineSection(
                            'Medicines Consumed Today', consumedMedicines, false),
                      if (missedMedicines.isNotEmpty)
                        buildMedicineSection(
                            'Missed Medicines', missedMedicines, true),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMedicineSection(String title, List<QueryDocumentSnapshot> medicines, bool isEditable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: medicines.length,
          itemBuilder: (context, index) {
            final doc = medicines[index];
            final medicine = doc.data() as Map<String, dynamic>;
            final id = doc.id;
            final name = medicine['name'] ?? 'No Name';
            final type = medicine['type'] ?? 'No Type';
            final quantity = medicine['quantity'] ?? 'No Quantity';
            final from = _getDate(medicine['duration']['from']) ?? DateTime.now();
            final to = _getDate(medicine['duration']['to']) ?? DateTime.now();
            final consumedToday = medicine['consumedToday'] ?? false;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),

                trailing: isEditable
                    ? Checkbox(
                  value: _checkedMedicines.contains(id),
                  onChanged: (isChecked) {
                    _toggleMedicine(id, isChecked ?? false);
                  },
                )
                    : null,
                onTap: () {
                  _showMedicineDetails(id);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
