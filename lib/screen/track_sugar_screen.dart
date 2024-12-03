import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;


class TrackSugarScreen extends StatefulWidget {
  @override
  _TrackSugarScreenState createState() => _TrackSugarScreenState();
}

class _TrackSugarScreenState extends State<TrackSugarScreen> {
  List<charts.Series<GlucoseReading, DateTime>> _seriesData = [];
  String recentValue = '';
  String recentDate = '';
  List<GlucoseReading> _allRecords = [];
  List<GlucoseReading> _latestSevenRecords = [];
  List<GlucoseReading> _latestTenRecords = [];
  String patientName = '';
  int totalValuesEntered = 0;
  int valuesInRange = 0;
  int valuesOutOfRange = 0;
  double afterMealSpikesPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    fetchPatientName();
    fetchGlucoseData();
  }

  Future<void> fetchGlucoseData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('glucoseReadings')
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var mostRecentDoc = snapshot.docs.first.data() as Map<String, dynamic>?;

        if (mostRecentDoc != null &&
            mostRecentDoc.containsKey('value') &&
            mostRecentDoc.containsKey('timestamp')) {
          setState(() {
            recentValue = mostRecentDoc['value'].toString();
            recentDate = DateFormat('dd-MM-yyyy').format(mostRecentDoc['timestamp'].toDate());
          });
        }

        List<GlucoseReading> dataPoints = snapshot.docs
            .map((doc) {
          var data = doc.data() as Map<String, dynamic>?;

          if (data != null &&
              data.containsKey('value') &&
              data.containsKey('timestamp')) {
            DateTime date = data['timestamp'].toDate();
            double value = double.parse(data['value'].toString());
            return GlucoseReading(date, value);
          }
          return null;
        })
            .where((reading) => reading != null)
            .cast<GlucoseReading>()
            .toList();

        // Calculate total values, in-range, and out-of-range counts
        totalValuesEntered = dataPoints.length;
        valuesInRange = dataPoints.where((reading) => reading.value >= 70 && reading.value <= 99).length;
        valuesOutOfRange = totalValuesEntered - valuesInRange;

        // Calculate after meal spikes percentage
        int afterMealSpikes = dataPoints.where((reading) => reading.value > 125).length; // Assuming > 125 as spike
        if (totalValuesEntered > 0) {
          afterMealSpikesPercentage = (afterMealSpikes / totalValuesEntered) * 100;
        }

        setState(() {
          _seriesData = [
            charts.Series<GlucoseReading, DateTime>(
              id: 'Glucose',
              colorFn: (GlucoseReading reading, _) =>
                  _getColorForGlucoseLevel(reading.value),
              domainFn: (GlucoseReading reading, _) => reading.date,
              measureFn: (GlucoseReading reading, _) => reading.value,
              data: dataPoints,
              labelAccessorFn: (GlucoseReading reading, _) =>
              '${reading.value.toString()} mg/dl',
            )
          ];

          _allRecords = dataPoints;

          // Latest 7 entries
          _latestSevenRecords = dataPoints.take(7).toList();

          // Latest 10 entries
          _latestTenRecords = dataPoints.take(10).toList();
        });
      } else {
        setState(() {
          _seriesData = [];
          _allRecords = [];
          _latestSevenRecords = [];
          _latestTenRecords = [];
        });
      }
    } catch (e) {
      print('Error fetching glucose data: $e');
    }
  }

  Future<void> fetchPatientName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users') // Adjust collection name if needed
            .doc(uid)
            .get();

        if (snapshot.exists) {
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
          setState(() {
            patientName = data?['username'] ?? 'Unknown'; // Adjust field name if needed
          });
        } else {
          setState(() {
            patientName = 'Unknown';
          });
        }
      }
    } catch (e) {
      print('Error fetching patient name: $e');
    }
  }

  charts.Color _getColorForGlucoseLevel(double value) {
    if (value < 70) {
      return charts.MaterialPalette.red.shadeDefault;
    } else if (value >= 70 && value <= 99) {
      return charts.MaterialPalette.green.shadeDefault;
    } else if (value >= 100 && value <= 125) {
      return charts.MaterialPalette.yellow.shadeDefault;
    } else {
      return charts.MaterialPalette.red.shadeDefault;
    }
  }

  Color _getFlutterColorFromChartColor(charts.Color chartColor) {
    return Color.fromARGB(
      chartColor.a,
      chartColor.r,
      chartColor.g,
      chartColor.b,
    );
  }

  void _showValuePopup(GlucoseReading reading) {
    String status = '';
    IconData statusIcon;
    if (reading.value < 70) {
      status = 'Low';
      statusIcon = Icons.arrow_downward;
    } else if (reading.value >= 70 && reading.value <= 99) {
      status = 'Safe';
      statusIcon = Icons.check_circle;
    } else if (reading.value >= 100 && reading.value <= 125) {
      status = 'High';
      statusIcon = Icons.warning;
    } else {
      status = 'Critical';
      statusIcon = Icons.error;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Glucose Reading"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Value: ${reading.value} mg/dl"),
              Text("Date: ${DateFormat('dd-MM-yyyy').format(reading.date)}"),
              Text("Status: $status"),
              Icon(
                statusIcon,
                color: _getFlutterColorFromChartColor(
                    _getColorForGlucoseLevel(reading.value)),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAllRecords() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("All Glucose Records"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _allRecords.length,
              itemBuilder: (context, index) {
                final reading = _allRecords[index];
                String status = '';
                IconData statusIcon;
                if (reading.value < 70) {
                  status = 'Low';
                  statusIcon = Icons.arrow_downward;
                } else if (reading.value >= 70 && reading.value <= 99) {
                  status = 'Safe';
                  statusIcon = Icons.check_circle;
                } else if (reading.value >= 100 && reading.value <= 125) {
                  status = 'High';
                  statusIcon = Icons.warning;
                } else {
                  status = 'Critical';
                  statusIcon = Icons.error;
                }

                return ListTile(
                  leading: Icon(
                    statusIcon,
                    color: _getFlutterColorFromChartColor(
                        _getColorForGlucoseLevel(reading.value)),
                  ),
                  title: Text("Value: ${reading.value} mg/dl"),
                  subtitle: Text(
                      "Date: ${DateFormat('dd-MM-yyyy').format(reading.date)}\nStatus: $status"),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenRecords() async {
    await fetchPatientName();

    // Calculate average of last 10 entries
    double average = 0;
    if (_latestTenRecords.isNotEmpty) {
      average = _latestTenRecords
          .map((reading) => reading.value)
          .reduce((a, b) => a + b) /
          _latestTenRecords.length;
    }

    // Calculate percentage of values in range and out of range among last 10 observations
    int inRangeCount = _latestTenRecords
        .where((reading) => reading.value >= 70 && reading.value <= 99)
        .length;
    int outOfRangeCount = _latestTenRecords.length - inRangeCount;

    double inRangePercentage = (inRangeCount / _latestTenRecords.length) * 100;
    double outOfRangePercentage = (outOfRangeCount / _latestTenRecords.length) * 100;

    String startDate = _latestSevenRecords.isNotEmpty
        ? DateFormat('dd-MM-yyyy').format(_latestSevenRecords.last.date)
        : '';
    String endDate = _latestSevenRecords.isNotEmpty
        ? DateFormat('dd-MM-yyyy').format(_latestSevenRecords.first.date)
        : '';

    // Generate the report
    String report = _generateWeeklyReport();

    // Initialize the foodRoutineSection with a default value to avoid null issues
    Widget foodRoutineSection = Text(
      "No food routine available for the current glucose levels.",
      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
    );

    // Define the food routine section based on average glucose levels
    if (average >= 70 && average <= 99) {
      // Normal glucose range diet recommendations
      foodRoutineSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Food Routine (Normal Glucose Levels):",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Breakfast: Whole-grain toast with avocado, scrambled eggs, and a piece of fruit.",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Lunch: Grilled chicken, quinoa, and a leafy green salad with olive oil dressing.",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Snack: A handful of almonds or walnuts.",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Dinner: Baked fish (such as salmon), brown rice, and steamed vegetables.",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Tip: Drink plenty of water and include fiber-rich foods to maintain glucose balance.",
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ],
      );
    } else if (average >= 100 && average <= 125) {
      // Pre-diabetic glucose range diet recommendations
      foodRoutineSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Food Routine (Pre-diabetic Glucose Levels):",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Breakfast: Steel-cut oats with chia seeds, topped with berries and a sprinkle of cinnamon.",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Lunch: Turkey and vegetable stir-fry with cauliflower rice.",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Snack: Celery sticks with almond butter or hummus.",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Dinner: Grilled chicken with sweet potatoes and roasted Brussels sprouts.",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Tip: Avoid sugary snacks and refined carbohydrates. Focus on whole foods and portion control.",
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ],
      );
    } else if (average >= 126) {
      // Diabetic glucose range diet recommendations
      foodRoutineSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Food Routine (Diabetic Glucose Levels):",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Breakfast: Vegetable omelet with a small portion of low-glycemic fruits like berries.",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Lunch: Grilled salmon with a spinach and kale salad, topped with olive oil and lemon dressing.",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Snack: A small apple with peanut butter or a handful of unsalted nuts.",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Dinner: Stir-fried tofu with non-starchy vegetables like bell peppers and broccoli.",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Tip: Focus on low-glycemic foods, lean proteins, and avoid high-carb and sugary items. Drink plenty of water.",
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ],
      );
    }
    Future<File> _createPdf() async {

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(
                    "Patient Report",
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 20),

                  // Display patient name
                  pw.Text("Patient Name: $patientName", style: pw.TextStyle(fontSize: 16)),

                  // Display average glucose
                  pw.SizedBox(height: 10),
                  pw.Text("Average Glucose (Last 10 Entries): ${average.toStringAsFixed(2)} mg/dl", style: pw.TextStyle(fontSize: 14)),


                  // Display symptoms
                  pw.SizedBox(height: 10),
                  pw.Text("Trends: ${_generateWeeklyReport()}", style: pw.TextStyle(fontSize: 14)),

                  // Display latest 7 entries
                  pw.SizedBox(height: 20),
                  pw.Text("Latest 7 Entries:", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.ListView.builder(
                    itemCount: _latestSevenRecords.length,
                    itemBuilder: (context, index) {
                      final reading = _latestSevenRecords[index];
                      String date = DateFormat('dd-MM-yyyy').format(reading.date);
                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Date: $date", style: pw.TextStyle(fontSize: 14)),
                          pw.Text("Value: ${reading.value} mg/dl", style: pw.TextStyle(fontSize: 14)),
                          pw.SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );

      final output = await getExternalStorageDirectory();
      final file = File("${output!.path}/patient_report.pdf");

      await file.writeAsBytes(await pdf.save());
      return file;
    }

    // Function to download the report as PDF
    Future<void> _downloadReport() async {
      // Ensure permissions are granted
      if (await Permission.storage.request().isGranted) {
        File pdfFile = await _createPdf();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document downloaded to: ${pdfFile.path}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
      }
    }

    // Function to share the report as a PDF document
    Future<void> _shareReport() async {
      File pdfFile = await _createPdf();

      Share.shareFiles([pdfFile.path], text: 'Patient report for $patientName');
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(10),
          child: Scaffold(
            appBar: AppBar(title: Text("Patient Report")),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView( // Added to allow scrolling
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Patient Name: $patientName",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Total Values Entered: $totalValuesEntered",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Values In Range: $valuesInRange (${((valuesInRange / totalValuesEntered) * 100).toStringAsFixed(2)}%)",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Values Out of Range: $valuesOutOfRange (${((valuesOutOfRange / totalValuesEntered) * 100).toStringAsFixed(2)}%)",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "After Meal Spikes: ${afterMealSpikesPercentage.toStringAsFixed(2)}%",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Week Insights ($startDate - $endDate):",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(report),
                    SizedBox(height: 20),

                    // Add the food routine section here
                    foodRoutineSection,

                    SizedBox(height: 20),
                    Text(
                      "Latest 7 Entries:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _latestSevenRecords.length,
                      itemBuilder: (context, index) {
                        final reading = _latestSevenRecords[index];
                        String date = DateFormat('dd-MM-yyyy').format(reading.date);
                        return ListTile(
                          title: Text("Date: $date"),
                          subtitle: Text("Value: ${reading.value} mg/dl"),
                        );
                      },
                    ),

                    // Add buttons for download and share
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _shareReport,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.teal, // White text color
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Padding for better touch area
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                        ),
                      ),
                      child: Text(
                        "Share Document",
                        style: TextStyle(
                          fontSize: 16, // Increased font size for better readability
                        ),
                      ),
                    )],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  String _generateWeeklyReport() {
    if (_latestSevenRecords.isEmpty)
      return "No data available for the past week.";

    double firstValue = _latestSevenRecords.last.value;
    double lastValue = _latestSevenRecords.first.value;
    double totalChange = lastValue - firstValue;

    String trend = '';
    if (totalChange > 0) {
      trend = 'increase';
    } else if (totalChange < 0) {
      trend = 'decrease';
    } else {
      trend = 'no significant change';
    }

    String symptoms = '';

    double averageValue = _latestSevenRecords
        .map((reading) => reading.value)
        .reduce((a, b) => a + b) /
        _latestSevenRecords.length;

    if (averageValue > 125) {
      symptoms =
      'Consistently high glucose levels may indicate hyperglycemia. Symptoms may include increased thirst, frequent urination, fatigue.';
    } else if (averageValue < 70) {
      symptoms =
      'Consistently low glucose levels may indicate hypoglycemia. Symptoms may include dizziness, confusion, shakiness.';
    } else {
      symptoms =
      'Glucose levels are within the normal range. Maintain your current lifestyle.';
    }

    return "Over the past week, there has been a $trend of ${totalChange.abs().toStringAsFixed(2)} mg/dl in glucose levels.\n\n"
        "Average glucose level: ${averageValue.toStringAsFixed(2)} mg/dl.\n\n"
        "Symptoms: $symptoms";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Track Sugar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Log Book",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700, // Teal color for log book title
                    ),
                  ),
                  SizedBox(height: 10),
                  recentValue.isNotEmpty
                      ? Text(
                    "Most Recent Entry: $recentValue mg/dl on $recentDate",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.teal.shade600, // Slightly darker teal
                    ),
                  )
                      : Text(
                    "No recent glucose data available",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.teal.shade600, // Slightly darker teal
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Glucose Track",
                style: TextStyle(
                  fontSize: 24, // Increased font size for a more prominent title
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2, // Adding some spacing to the letters
                  color: Colors.teal.shade900, // Using a dark teal for the title
                ),
              ),
            ),
            Align(
              alignment: Alignment.center, // Aligns the container to the left
              child: Container(
                width: 350, // Set the desired width here
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4), // Adds a shadow to make the chart pop
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent.shade100, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SizedBox(
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                    child: charts.TimeSeriesChart(
                      _seriesData,
                      animate: true,
                      dateTimeFactory: const charts.LocalDateTimeFactory(),
                      primaryMeasureAxis: charts.NumericAxisSpec(
                        tickProviderSpec: charts.StaticNumericTickProviderSpec(
                          <charts.TickSpec<double>>[
                            charts.TickSpec(25),
                            charts.TickSpec(50),
                            charts.TickSpec(75),
                            charts.TickSpec(100),
                            charts.TickSpec(125),
                            charts.TickSpec(150),
                            charts.TickSpec(175),
                          ],
                        ),
                        renderSpec: charts.GridlineRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 14,
                            color: charts.MaterialPalette.white, // Better contrast with dark background
                          ),
                          lineStyle: charts.LineStyleSpec(
                            color: charts.MaterialPalette.white, // Gridline color improvement
                          ),
                        ),
                      ),

                      defaultRenderer: charts.LineRendererConfig(
                        includeArea: true, // Fill area for a more dynamic appearance
                        strokeWidthPx: 2.5, // Thicker line
                        includePoints: true,
                        radiusPx: 4.0, // Larger data points
                        dashPattern: [5, 3], // Dashed lines for a sleek, modern look
                      ),
                      selectionModels: [
                        charts.SelectionModelConfig(
                          type: charts.SelectionModelType.info,
                          changedListener: (charts.SelectionModel model) {
                            if (model.hasDatumSelection) {
                              final selectedDatum = model.selectedDatum.first.datum as GlucoseReading;
                              _showValuePopup(selectedDatum);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
              children: [
                ElevatedButton(
                  onPressed: _showAllRecords,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.teal, // White text color
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Increased padding for buttons
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                  child: Text(
                    "View All Records",
                    style: TextStyle(
                      fontSize: 16, // Increased font size for better readability
                    ),
                  ),
                ),
                SizedBox(width: 16), // Spacing between buttons
                ElevatedButton(
                  onPressed: _showFullScreenRecords,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.teal, // White text color
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Increased padding for buttons
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                  child: Text(
                    "Get Records",
                    style: TextStyle(
                      fontSize: 16, // Increased font size for better readability
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GlucoseReading {
  final DateTime date;
  final double value;

  GlucoseReading(this.date, this.value);
}
