import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuple/tuple.dart';

class KnowYourFoodScreen extends StatefulWidget {
  @override
  _KnowYourFoodScreenState createState() => _KnowYourFoodScreenState();
}

class _KnowYourFoodScreenState extends State<KnowYourFoodScreen> {
  double _averageGlucose = 0.0;
  bool _isHeartbeatEntered = false;
  String _enteredHeartbeat = '';
  List<Map<String, String>> _insights = [];

  @override
  void initState() {
    super.initState();
    _fetchAverageGlucose();
  }

  Future<void> _fetchAverageGlucose() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userHealthChecks = await FirebaseFirestore.instance
            .collection('healthChecks')
            .where('userId', isEqualTo: user.uid)
            .get();

        if (userHealthChecks.docs.isNotEmpty) {
          double totalCarbs = userHealthChecks.docs.fold(
              0.0, (sum, doc) {
            final data = doc.data();
            final carbs = data['totalCarbs'] as double? ?? 0.0;
            return sum + carbs;
          });

          setState(() {
            _averageGlucose = totalCarbs / userHealthChecks.docs.length;
          });
        } else {
          setState(() {
            _averageGlucose = 0.0;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch average glucose: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
    }
  }

  void _onSubmitted(String value) {
    setState(() {
      _enteredHeartbeat = value;
      _isHeartbeatEntered = true;
      _generateInsights();
    });
  }

  void _generateInsights() {
    final double heartbeat = double.tryParse(_enteredHeartbeat) ?? 0.0;
    List<Map<String, String>> insights = [];

    if (heartbeat > 0) {
      insights.add(_evaluateInsight(
        title: 'Glucose-Heart Rate Correlation',
        conditions: [
          Tuple3(heartbeat <= 100 && _averageGlucose < 140, 'Safe', 'Maintain a balanced diet and moderate exercise.'),
          Tuple3(heartbeat > 100 && heartbeat <= 120 && _averageGlucose >= 140 && _averageGlucose <= 180, 'Unsafe', 'Reduce sugar intake and eat smaller, frequent meals.'),
          Tuple3(heartbeat > 120 && _averageGlucose > 180, 'Critical', 'Seek medical advice; manage with low-GI foods and possibly medication.')
        ],
      ));

      insights.add(_evaluateInsight(
        title: 'Meal-Specific Metabolic Response',
        conditions: [
          Tuple3(_averageGlucose < 140 && (heartbeat - _averageGlucose).abs() < 20, 'Safe', 'Include fiber and protein in meals.'),
          Tuple3(_averageGlucose >= 140 && _averageGlucose <= 180 && (heartbeat - _averageGlucose).abs() >= 20 && (heartbeat - _averageGlucose).abs() <= 30, 'Unsafe', 'Limit carbs and increase activity after meals.'),
          Tuple3(_averageGlucose > 180 && (heartbeat - _averageGlucose).abs() > 30, 'Critical', 'Monitor closely and consult a doctor for glucose management.')
        ],
      ));

      insights.add(_evaluateInsight(
        title: 'Monitoring Hypoglycemia Events',
        conditions: [
          Tuple3(_averageGlucose >= 70 && _averageGlucose <= 100 && (heartbeat - _averageGlucose).abs() < 10, 'Safe', 'Maintain regular meal times with complex carbs.'),
          Tuple3(_averageGlucose >= 60 && _averageGlucose < 70 && (heartbeat - _averageGlucose).abs() >= 10, 'Unsafe', 'Have a quick carb source (juice, glucose tablets).'),
          Tuple3(_averageGlucose < 60 && (heartbeat - _averageGlucose).abs() >= 20, 'Critical', 'Immediate glucose intake and emergency medical care.')
        ],
      ));

      insights.add(_evaluateInsight(
        title: 'Exercise and Recovery',
        conditions: [
          Tuple3(heartbeat >= 50 && heartbeat <= 85 && _averageGlucose >= 70 && _averageGlucose <= 140, 'Safe', 'Pre-exercise carbs and hydration.'),
          Tuple3(heartbeat > 85 && heartbeat <= 95 && _averageGlucose >= 140 && _averageGlucose <= 180, 'Unsafe', 'Cool down and hydrate; monitor recovery.'),
          Tuple3(heartbeat > 95 && _averageGlucose > 180, 'Critical', 'Stop exercising, hydrate, and seek medical advice if needed.')
        ],
      ));

      insights.add(_evaluateInsight(
        title: 'Cardiac Stress from High Glucose Levels',
        conditions: [
          Tuple3(heartbeat >= 60 && heartbeat <= 100 && _averageGlucose < 140, 'Safe', 'Maintain physical activity and a balanced diet.'),
          Tuple3(heartbeat > 100 && heartbeat <= 120 && _averageGlucose >= 140 && _averageGlucose <= 180, 'Unsafe', 'Reduce refined carbs, increase physical activity.'),
          Tuple3(heartbeat > 120 && _averageGlucose > 180, 'Critical', 'Immediate lifestyle intervention or medical consultation.')
        ],
      ));

      insights.add(_evaluateInsight(
        title: 'Time of Day Influence',
        conditions: [
          Tuple3(_averageGlucose < 140 && heartbeat >= 60 && heartbeat <= 80, 'Safe', 'Eat a light, balanced dinner.'),
          Tuple3(_averageGlucose >= 140 && _averageGlucose <= 160 && heartbeat > 80 && heartbeat <= 90, 'Unsafe', 'Limit evening carb intake.'),
          Tuple3(_averageGlucose > 160 && heartbeat > 90, 'Critical', 'Avoid late heavy meals and consider professional evaluation.')
        ],
      ));

      insights.add(_evaluateInsight(
        title: 'Impact of Meals on Sleep',
        conditions: [
          Tuple3(_averageGlucose < 140 && heartbeat >= 60 && heartbeat <= 70, 'Safe', 'Eat low-carb meals at least 2 hours before bed.'),
          Tuple3(_averageGlucose >= 140 && _averageGlucose <= 160 && heartbeat > 70 && heartbeat <= 80, 'Unsafe', 'Avoid heavy dinners, reduce sugar and fats at night.'),
          Tuple3(_averageGlucose > 160 && heartbeat > 80, 'Critical', 'Seek medical guidance to prevent sleep disruptions.')
        ],
      ));

      insights.add(_evaluateInsight(
        title: 'Personalized Meal Planning',
        conditions: [
          Tuple3(_averageGlucose >= 70 && _averageGlucose <= 100 && heartbeat >= 60 && heartbeat <= 80, 'Safe', 'Follow a balanced diet and regular physical activity.'),
          Tuple3(_averageGlucose > 100 && _averageGlucose <= 125 && heartbeat > 80 && heartbeat <= 100, 'Unsafe', 'Adjust diet to reduce sugar and processed carbs.'),
          Tuple3(_averageGlucose > 125 && heartbeat > 100, 'Critical', 'Immediate lifestyle change and medical intervention.')
        ],
      ));
    }

    setState(() {
      _insights = insights;
    });
  }

  Map<String, String> _evaluateInsight({
    required String title,
    required List<Tuple3<bool, String, String>> conditions,
  }) {
    for (var condition in conditions) {
      if (condition.item1) {
        return {
          'title': title,
          'status': condition.item2,
          'remedy': condition.item3,
        };
      }
    }
    return {
      'title': title,
      'status': 'Normal',
      'remedy': 'No specific advice needed. Maintain a balanced diet and healthy lifestyle.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Know Your Food"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Enter the Heartbeat",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            Text(
              "Make sure you are calm and settled.",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.0),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Heartbeat (BPM)",
                hintText: "Enter heartbeat in BPM",
                prefixIcon: Icon(Icons.favorite, color: Colors.teal),
              ),
              onSubmitted: _onSubmitted,
            ),
            SizedBox(height: 24.0),
            Expanded(
              child: ListView.builder(
                itemCount: _insights.length,
                itemBuilder: (context, index) {
                  final insight = _insights[index];
                  final status = insight['status'] ?? 'Normal';
                  final remedy = insight['remedy'] ?? '';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(
                        status == 'Normal'
                            ? Icons.check_circle_outline
                            : status == 'Safe'
                            ? Icons.thumb_up
                            : status == 'Critical'
                            ? Icons.warning
                            : Icons.error_outline,
                        color: status == 'Normal'
                            ? Colors.green
                            : status == 'Safe'
                            ? Colors.blue
                            : status == 'Critical'
                            ? Colors.red
                            : Colors.orange,
                      ),
                      title: Text(insight['title'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Status: $status'),
                          SizedBox(height: 4.0),
                          Text('Remedy: $remedy'),
                        ],
                      ),
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
