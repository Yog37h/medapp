import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/screen/StarScreen.dart';

class MedicalEquipmentPage extends StatefulWidget {
  @override
  _MedicalEquipmentPageState createState() => _MedicalEquipmentPageState();
}

class _MedicalEquipmentPageState extends State<MedicalEquipmentPage> {
  String username = "";
  String locationText = "Fetching the location...";
  bool isLocationFetched = false;
  List<Map<String, dynamic>> equipment = [];
  List<Map<String, dynamic>> filteredEquipment = [];
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _populateEquipment();
    _simulateLocationFetch();
  }

  void _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        username = snapshot['username'] ?? "User";
      });
    }
  }

  void _simulateLocationFetch() {
    Timer(Duration(seconds: 6), () {
      setState(() {
        isLocationFetched = true;
        locationText = "PSGiTech, Neelambur, Coimbatore";
      });
    });
  }

  void _populateEquipment() {
    equipment = [
      {
        "name": "Digital Thermometer",
        "description": "Provides accurate temperature readings quickly.",
        "cost": 1200,
        "icon": Icons.thermostat,
        "benefits": "Helps in monitoring body temperature accurately.",
        "usage": "Use as per manufacturer's instructions."
      },
      {
        "name": "Blood Pressure Monitor",
        "description": "Monitors blood pressure with ease.",
        "cost": 2500,
        "icon": Icons.monitor_heart,
        "benefits": "Assists in managing hypertension and cardiovascular health.",
        "usage": "Use regularly as prescribed by healthcare provider."
      },
      {
        "name": "Digital Blood Pressure Monitor",
        "description": "Measures blood pressure quickly and accurately.",
        "cost": 100,
        "icon": Icons.monitor_weight,
        "benefits": "Enables patients to monitor their blood pressure at home, helping to manage hypertension.",
        "usage": "Follow the device instructions; typically involves wrapping a cuff around the arm."
      },
      {
        "name": "Pulse Oximeter",
        "description": "Measures the oxygen saturation level in the blood.",
        "cost": 40,
        "icon": Icons.health_and_safety,
        "benefits": "Essential for patients with respiratory conditions to monitor their oxygen levels.",
        "usage": "Place the device on a fingertip and read the display."
      },

      {
        "name": "Heart Rate Monitor",
        "description": "Tracks heart rate during exercise or daily activities.",
        "cost": 100,
        "icon": Icons.favorite,
        "benefits": "Helps patients keep track of their cardiovascular health.",
        "usage": "Wear as instructed; may include chest straps or wrist devices."
      },
      {
        "name": "Electric Heating Pad",
        "description": "Provides soothing heat therapy to relieve muscle and joint pain.",
        "cost": 25,
        "icon": Icons.favorite,
        "benefits": "Helps alleviate pain and improves blood circulation.",
        "usage": "Apply to the affected area as needed; follow the manufacturer's instructions."
      },
      {
        "name": "Cold Therapy Gel Pack",
        "description": "Reusable gel pack for cold therapy.",
        "cost": 15,
        "icon": Icons.ac_unit,
        "benefits": "Reduces swelling and numbs pain in acute injuries.",
        "usage": "Freeze before use; apply to the affected area for 15-20 minutes."
      },
      {
        "name": "TENS Unit",
        "description": "Transcutaneous electrical nerve stimulation device for pain relief.",
        "cost": 80,
        "icon": Icons.electric_bolt,
        "benefits": "Provides drug-free pain relief for various conditions.",
        "usage": "Attach electrodes to the skin and set desired intensity."
      },
      {
        "name": "Massage Gun",
        "description": "Portable device for muscle relaxation and recovery.",
        "cost": 150,
        "icon": Icons.spa,
        "benefits": "Helps relieve muscle tension and soreness.",
        "usage": "Use on targeted muscles, moving slowly for effective relief."
      },
      {
        "name": "Inhaler",
        "description": "Delivers medication directly to the lungs.",
        "cost": 30,
        "icon": Icons.air,
        "benefits": "Essential for managing asthma and other respiratory conditions.",
        "usage": "Follow doctor's instructions on usage and dosage."
      },
      {
        "name": "Nebulizer",
        "description": "Device that turns liquid medicine into mist for easy inhalation.",
        "cost": 100,
        "icon": Icons.healing,
        "benefits": "Helps deliver medication for respiratory issues effectively.",
        "usage": "Connect the mask to the device and breathe in the mist."
      },
      {
        "name": "Therapeutic Foot Spa",
        "description": "Soothing spa treatment for tired feet.",
        "cost": 60,
        "icon": Icons.directions_run,
        "benefits": "Provides relaxation and improves circulation in the feet.",
        "usage": "Fill with water and add essential oils as desired."
      },
      {
        "name": "Compression Socks",
        "description": "Supports blood circulation in the legs.",
        "cost": 20,
        "icon": Icons.support_agent,
        "benefits": "Reduces swelling and discomfort during long periods of sitting or standing.",
        "usage": "Wear as directed, especially during travel or long hours of sitting."
      },
      {
        "name": "Orthopedic Brace",
        "description": "Provides support to injured or weak joints.",
        "cost": 45,
        "icon": Icons.support,
        "benefits": "Helps stabilize joints and aids in recovery.",
        "usage": "Follow instructions for fitting and wearing duration."
      },
      {
        "name": "At-Home ECG Monitor",
        "description": "Provides electrocardiogram readings to monitor heart rhythm.",
        "cost": 200,
        "icon": Icons.monitor,
        "benefits": "Enables early detection of arrhythmias and other heart conditions.",
        "usage": "Follow the instructions for electrode placement and reading."
      },
      {
        "name": "Body Composition Scale",
        "description": "Measures weight along with body fat percentage, muscle mass, and water content.",
        "cost": 100,
        "icon": Icons.scale,
        "benefits": "Provides a comprehensive view of overall health and fitness.",
        "usage": "Stand on the scale and follow the display instructions."
      },
      {
        "name": "Peak Flow Meter",
        "description": "Measures how well air moves out of the lungs.",
        "cost": 30,
        "icon": Icons.air,
        "benefits": "Useful for patients with asthma to monitor lung function.",
        "usage": "Exhale forcefully into the device and read the measurement."
      },
      {
        "name": "Tympanic Thermometer",
        "description": "Measures body temperature through the ear.",
        "cost": 50,
        "icon": Icons.thermostat,
        "benefits": "Provides quick temperature readings, ideal for children.",
        "usage": "Insert gently into the ear canal and press the button."
      },
      {
        "name": "Walking Aid",
        "description": "A device that assists individuals in walking.",
        "cost": 100,
        "icon": Icons.accessibility,
        "benefits": "Provides support and stability while walking.",
        "usage": "Use as per instructions for safe walking."
      },
      {
        "name": "Resistance Bands",
        "description": "Elastic bands used for strength training and rehabilitation.",
        "cost": 20,
        "icon": Icons.fitness_center,
        "benefits": "Helps in muscle strengthening and rehabilitation exercises.",
        "usage": "Incorporate into exercise routines as directed."
      },
      {
        "name": "Therapy Balls",
        "description": "Large inflatable balls used for exercise and rehabilitation.",
        "cost": 30,
        "icon": Icons.circle,
        "benefits": "Improves balance, flexibility, and strength.",
        "usage": "Use under supervision for best results."
      },
      {
        "name": "Walking Frame",
        "description": "A frame that provides support for walking.",
        "cost": 150,
        "icon": Icons.run_circle_sharp,
        "benefits": "Enhances stability and confidence while walking.",
        "usage": "Ensure proper height adjustment for comfort."
      },
      {
        "name": "Gait Trainer",
        "description": "A device designed to help individuals learn to walk.",
        "cost": 500,
        "icon": Icons.track_changes,
        "benefits": "Facilitates gait training for improved mobility.",
        "usage": "Use under professional supervision for optimal results."
      },
      {
        "name": "Electric Stimulator",
        "description": "A device that uses electrical impulses for muscle stimulation.",
        "cost": 200,
        "icon": Icons.flash_on,
        "benefits": "Assists in muscle recovery and pain relief.",
        "usage": "Follow guidelines for safe application."
      },
      {
        "name": "Therapy Mat",
        "description": "A padded mat for safe exercise and rehabilitation.",
        "cost": 80,
        "icon": Icons.safety_divider,
        "benefits": "Provides a safe surface for various rehabilitation exercises.",
        "usage": "Use for stretching, strength training, and balance exercises."
      },
      {
        "name": "Step Platform",
        "description": "A platform used for step exercises and rehabilitation.",
        "cost": 50,
        "icon": Icons.arrow_upward,
        "benefits": "Enhances strength and balance through step exercises.",
        "usage": "Use with caution and adjust height as needed."
      },
      {
        "name": "Cane",
        "description": "A stick used to assist with walking.",
        "cost": 25,
        "icon": Icons.assignment,
        "benefits": "Provides support and stability to improve mobility.",
        "usage": "Adjust height for comfort and safety."
      },
      {
        "name": "Shoulder Pulley",
        "description": "A device used for shoulder rehabilitation exercises.",
        "cost": 40,
        "icon": Icons.repeat,
        "benefits": "Assists in restoring range of motion in the shoulder.",
        "usage": "Follow prescribed exercises for effective rehabilitation."
      },
      {
        "name": "Smart Wearable Devices (Fitness Trackers)",
        "description": "Monitors various health metrics such as heart rate, sleep patterns, and activity levels.",
        "cost": 150,
        "icon": Icons.fitness_center,
        "benefits": "Helps individuals maintain an active lifestyle and monitor their health.",
        "usage": "Wear as instructed and sync with a smartphone app for detailed tracking."
      },

      {
        "name": "Pulse Oximeter",
        "description": "Measures the oxygen saturation level in the blood.",
        "cost": 40,
        "icon": Icons.health_and_safety,
        "benefits": "Essential for patients with respiratory conditions to monitor their oxygen levels.",
        "usage": "Place the device on a fingertip and read the display."
      },
      {
        "name": "Heart Rate Monitor",
        "description": "Tracks heart rate during exercise or daily activities.",
        "cost": 100,
        "icon": Icons.favorite,
        "benefits": "Helps patients keep track of their cardiovascular health.",
        "usage": "Wear as instructed; may include chest straps or wrist devices."
      },
      {
        "name": "Body Composition Scale",
        "description": "Measures weight along with body fat percentage, muscle mass, and water content.",
        "cost": 100,
        "icon": Icons.scale,
        "benefits": "Provides a comprehensive view of overall health and fitness.",
        "usage": "Stand on the scale and follow the display instructions."
      },
      {
        "name": "Peak Flow Meter",
        "description": "Measures how well air moves out of the lungs.",
        "cost": 30,
        "icon": Icons.air,
        "benefits": "Useful for patients with asthma to monitor lung function.",
        "usage": "Exhale forcefully into the device and read the measurement."
      },
      {
        "name": "Tympanic Thermometer",
        "description": "Measures body temperature through the ear.",
        "cost": 50,
        "icon": Icons.thermostat,
        "benefits": "Provides quick temperature readings, ideal for children.",
        "usage": "Insert gently into the ear canal and press the button."
      },
      {
        "name": "Smart Wearable Devices (Fitness Trackers)",
        "description": "Monitors various health metrics such as heart rate, sleep patterns, and activity levels.",
        "cost": 150,
        "icon": Icons.fitness_center,
        "benefits": "Helps individuals maintain an active lifestyle and monitor their health.",
        "usage": "Wear as instructed and sync with a smartphone app for detailed tracking."
      },
      {
        "name": "Scalpel",
        "description": "A small, sharp knife used for surgical incisions.",
        "cost": 10,
        "icon": Icons.cut,
        "benefits": "Provides precision in making incisions during surgery.",
        "usage": "Use with caution and follow sterilization procedures."
      },
      {
        "name": "Surgical Scissors",
        "description": "Used for cutting tissue during surgical procedures.",
        "cost": 15,
        "icon": Icons.scale_sharp,
        "benefits": "Essential for various surgical tasks, including dissection.",
        "usage": "Utilize as per surgical protocols."
      },
      {
        "name": "Hemostatic Forceps",
        "description": "Used to control bleeding during surgery.",
        "cost": 25,
        "icon": Icons.healing,
        "benefits": "Essential for clamping blood vessels to prevent excessive bleeding.",
        "usage": "Apply pressure to clamp blood vessels during procedures."
      },
      {
        "name": "Needle Holder",
        "description": "Instrument used to hold needles while suturing.",
        "cost": 20,
        "icon": Icons.pin,
        "benefits": "Provides stability when suturing tissues together.",
        "usage": "Grip the needle securely to ensure precise suturing."
      },
      {
        "name": "Suction Device",
        "description": "Removes blood and fluids from the surgical site.",
        "cost": 100,
        "icon": Icons.remove_circle,
        "benefits": "Maintains a clear surgical field by removing excess fluids.",
        "usage": "Follow instructions for connecting and operating."
      },
      {
        "name": "Electrosurgical Unit",
        "description": "Uses high-frequency electrical currents for cutting and coagulation.",
        "cost": 500,
        "icon": Icons.power,
        "benefits": "Reduces bleeding and minimizes tissue damage.",
        "usage": "Use per manufacturer's guidelines for settings."
      },
      {
        "name": "Scissors for Bandages",
        "description": "Specially designed scissors for cutting bandages.",
        "cost": 8,
        "icon": Icons.style,
        "benefits": "Provides safety and ease when cutting bandages.",
        "usage": "Utilize to safely remove or adjust bandages."
      },
      {
        "name": "Forceps",
        "description": "Used to grasp or hold tissues during surgery.",
        "cost": 15,
        "icon": Icons.mic,
        "benefits": "Essential for manipulating tissues and organs.",
        "usage": "Apply appropriately depending on the surgical context."
      },
      {
        "name": "Surgical Drapes",
        "description": "Used to cover and protect the surgical area.",
        "cost": 30,
        "icon": Icons.local_convenience_store_rounded,
        "benefits": "Maintains a sterile environment during surgery.",
        "usage": "Apply drapes as per sterile protocol."
      },
      {
        "name": "Bovie Tip",
        "description": "Used for electrosurgery to cut and coagulate tissue.",
        "cost": 50,
        "icon": Icons.flash_on,
        "benefits": "Minimizes blood loss and tissue damage.",
        "usage": "Attach to electrosurgical unit and follow instructions."
      }
    ];
    _applyFilters(); // Initial filter application
  }

  void _addToCart(Map<String, dynamic> equipmentItem) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cartproduct') // Updated collection name
            .add({
          'name': equipmentItem['name'],
          'description': equipmentItem['description'],
          'cost': equipmentItem['cost'],
          'timestamp': FieldValue.serverTimestamp(),
          // Optionally, track when the item was added
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${equipmentItem['name']} added to cart!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to add ${equipmentItem['name']} to cart!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not authenticated!")),
      );
    }
  }


  void _applyFilters() {
    setState(() {
      filteredEquipment = equipment.where((item) {
        final itemName = item['name'].toLowerCase();
        final itemDescription = item['description'].toLowerCase();
        final searchQuery = _searchController.text.toLowerCase();
        final categoryMatches = selectedCategory == 'All' ||
            itemDescription.contains(selectedCategory.toLowerCase());

        return categoryMatches && (itemName.contains(searchQuery) ||
            itemDescription.contains(searchQuery));
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _applyFilters();
  }

  void _showEquipmentDetails(Map<String, dynamic> equipmentItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipmentItem['name'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(equipmentItem['description']),
                  SizedBox(height: 8),
                  Text(
                    "₹${equipmentItem['cost']}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Benefits: ${equipmentItem['benefits']}",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Usage: ${equipmentItem['usage']}",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Add to Cart'),
                  onPressed: () {
                    _addToCart(equipmentItem);
                    Navigator.of(context).pop();
                  },
                ),

              ],
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
        title: Text('Medical Equipment'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Deliver to $username",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.star, color: Colors.teal),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StarScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            AnimatedOpacity(
              opacity: isLocationFetched ? 1.0 : 0.5,
              duration: Duration(seconds: 1),
              child: Text(
                locationText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search Equipment',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredEquipment.length,
                itemBuilder: (context, index) {
                  final equipmentItem = filteredEquipment[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(equipmentItem['icon']),
                      title: Text(equipmentItem['name']),
                      subtitle: Text(equipmentItem['description']),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₹${equipmentItem['cost']}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      onTap: () => _showEquipmentDetails(equipmentItem),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
