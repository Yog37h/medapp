import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GlucoseMonitoringScreen extends StatefulWidget {
  @override
  _GlucoseMonitoringScreenState createState() =>
      _GlucoseMonitoringScreenState();
}

class _GlucoseMonitoringScreenState extends State<GlucoseMonitoringScreen> {
  String selectedReadingType = 'Fasting';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TextEditingController glucoseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.teal),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    "Glucose Monitoring",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      TextField(
                        controller: glucoseController,
                        decoration: InputDecoration(
                          labelText: "Glucose Value (mg/dl)",
                          labelStyle: TextStyle(color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal, width: 2),
                          ),
                          contentPadding: EdgeInsets.all(16),
                          hintText: "Enter glucose value",
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      SizedBox(height: 20),
                      Divider(color: Colors.teal.shade100),
                      SizedBox(height: 10),
                      Text(
                        "Reading Type",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          _buildReadingTypeButton("Fasting"),
                          _buildReadingTypeButton("Random"),
                          _buildReadingTypeButton("Before Meal"),
                          _buildReadingTypeButton("After Meal"),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Reading Date",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          DateFormat('dd-MM-yyyy').format(selectedDate),
                          style: TextStyle(color: Colors.teal.shade700),
                        ),
                        trailing: Icon(Icons.calendar_today, color: Colors.teal),
                        onTap: _pickDate,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Reading Time",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          selectedTime.format(context),
                          style: TextStyle(color: Colors.teal.shade700),
                        ),
                        trailing: Icon(Icons.access_time, color: Colors.teal),
                        onTap: _pickTime,
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          _saveGlucoseData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadingTypeButton(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedReadingType = label;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: selectedReadingType == label ? Colors.teal : Colors.teal.shade50,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.teal,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selectedReadingType == label
                  ? Colors.white
                  : Colors.teal.shade700,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate)
      setState(() {
        selectedDate = pickedDate;
      });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime)
      setState(() {
        selectedTime = pickedTime;
      });
  }

  void _saveGlucoseData() {
    int glucoseValue = int.tryParse(glucoseController.text) ?? 0;
    String status = "Normal";
    Color statusColor = Colors.green;
    String statusMessage = "Glucose levels are normal and safe.";
    String remedyMessage = "";

    // Define glucose level ranges for different reading types
    Map<String, List<int>> ranges = {
      "Fasting": [70, 100, 126], // Low, Normal, High
      "Random": [80, 140, 200],
      "Before Meal": [70, 130, 180],
      "After Meal": [90, 140, 200],
    };

    List<int> currentRange = ranges[selectedReadingType]!;

    // Determine status based on glucose value
    if (glucoseValue < currentRange[0]) {
      status = "Low";
      statusColor = Colors.yellow;
      statusMessage =
      "Glucose levels are low. Better to consult a doctor in prior.";
      remedyMessage = "Consider having some fruit juice or sugary snacks.";
    } else if (glucoseValue >= currentRange[0] &&
        glucoseValue <= currentRange[1]) {
      status = "Normal";
      statusColor = Colors.green;
      statusMessage = "Glucose levels are normal and safe.";
    } else if (glucoseValue > currentRange[1] &&
        glucoseValue < currentRange[2]) {
      status = "High";
      statusColor = Colors.orange;
      statusMessage = "Glucose levels are high. Monitor regularly.";
      remedyMessage = "Consider eating foods rich in fiber and low in sugar.";
    } else if (glucoseValue >= currentRange[2]) {
      status = "Critical";
      statusColor = Colors.red;
      statusMessage =
      "Glucose levels are critical. Immediate medical attention required.";
      remedyMessage = "Seek medical attention immediately.";
    }

    // Save data to Firebase
    FirebaseFirestore.instance.collection('glucoseReadings').add({
      'value': glucoseValue,
      'readingType': selectedReadingType,
      'timestamp': DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
      'status': status,
    }).then((_) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
        return Dialog(
            child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  Text(
                  "Glucose Level: $status",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor,
                      width: 4,
                    ),
                    color: statusColor.withOpacity(0.3),
                  ),
                  child: Center(
                    child: Text(
                      "$glucoseValue mg/dl",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  statusMessage,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                if (remedyMessage.isNotEmpty) ...[
            SizedBox(height: 10),
      Text(
      "Suggested Remedy: $remedyMessage",
      style: TextStyle(
      fontSize: 16, fontStyle: FontStyle.italic),
      textAlign: TextAlign.center,
      ),
      ],
      SizedBox(height: 20),
      // Glucose level bar
      Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.grey[200],
      ),
      child: Stack(
      children: [
      FractionallySizedBox(
      widthFactor: glucoseValue / currentRange[2],
      child: Container(
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),

        color: statusColor,
      ),
      ),
      ),
        Positioned.fill(
          child: Center(
            child: Text(
              "Optimal: ${currentRange[0]}-${currentRange[1]} mg/dl",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
      ),
      ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Implement save functionality here
                          },
                          child: Text("Save"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Close"),
                        ),
                      ],
                    ),
                  ],
                ),
            ),
        );
          },
      );
    });
  }
}

