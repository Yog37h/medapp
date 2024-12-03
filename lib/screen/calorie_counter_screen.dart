import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/data/fooddata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_to_do_list/model/model.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_to_do_list/screen/food_summary_screen.dart'; // Import the new screen

class CalorieCounterScreen extends StatefulWidget {
  @override
  _CalorieCounterScreenState createState() => _CalorieCounterScreenState();
}

class _CalorieCounterScreenState extends State<CalorieCounterScreen> {
  String? userInitial = ''; // User's first letter
  DateTime selectedDate = DateTime.now(); // Default to current date
  String selectedMealPeriod = 'All Meals'; // Default meal period
  String searchQuery = ''; // Search bar query
  Map<FoodItem, double> addedFoodItems = {}; // Store added food items and quantities
  bool showCart = false; // Flag to control cart visibility

  @override
  void initState() {
    super.initState();
    _fetchUserInitial(); // Fetch user data on screen load
  }

  Future<void> _fetchUserInitial() async {
    // Get the currently logged-in user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch user's name from Firestore using user ID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Use the logged-in user's UID
          .get();
      setState(() {
        userInitial = userDoc.data()?['username']?.substring(0, 1).toUpperCase() ?? 'U';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  void _showQuantityDialog(BuildContext context, FoodItem foodItem) {
    double selectedQuantity = 1.0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Quantity'),
          content: Container(
            height: 250, // Set a fixed height for the dialog content
            child: Column(
              children: [
                Expanded(
                  child: ListWheelScrollView(
                    itemExtent: 50, // Height of each item
                    diameterRatio: 1.5,
                    useMagnifier: true,
                    magnification: 1.5,
                    onSelectedItemChanged: (index) {
                      selectedQuantity = 1 + (index * 0.5);
                    },
                    children: List<Widget>.generate(
                      19, // For values 1 to 10 with 0.5 increments
                          (index) => Center(
                        child: Text(
                          (1 + (index * 0.5)).toStringAsFixed(1),
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addFoodItem(foodItem, selectedQuantity);
              },
              child: Text('Add Food'),
            ),
          ],
        );
      },
    );
  }

  void _addFoodItem(FoodItem foodItem, double quantity) {
    setState(() {
      addedFoodItems[foodItem] = quantity;
      showCart = true;
    });
  }

  @override
  Widget build(BuildContext context) {
       List<FoodItem> filteredFoodItems = foodItems
        .where((item) => item.name.toLowerCase().contains(searchQuery))
        .toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40), // Top margin
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Food Logging", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
                CircleAvatar(
                  child: Text(userInitial ?? '', style: TextStyle(fontSize: 20, color: Colors.white)),
                  backgroundColor: Colors.teal,
                  radius: 20,
                ),
              ],
            ),
            SizedBox(height: 20), // Space between header and date picker

            // Date Selector Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date Selector
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.teal),
                      SizedBox(width: 8),
                      Text(
                        DateFormat('yyyy-MM-dd').format(selectedDate),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ],
                  ),
                ),

                // Meal Period Selector Dropdown
                DropdownButton<String>(
                  value: selectedMealPeriod,
                  items: <String>[
                    'All Meals',
                    'Early Morning',
                    'Breakfast',
                    'Mid Morning',
                    'Lunch',
                    'Evening Snack',
                    'Dinner',
                    'Bed Time',
                    'Others'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.teal)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMealPeriod = newValue!;
                    });
                  },
                ),
              ],
            ),

            // "Your Meal" section
            SizedBox(height: 20),
            Text("Your Meal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
            SizedBox(height: 20),

            // Search bar
            TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for food',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            SizedBox(height: 20),

            // List of food items
            Expanded(
              child: ListView.builder(
                itemCount: filteredFoodItems.length,
                itemBuilder: (context, index) {
                  final food = filteredFoodItems[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Text(food.logo, style: TextStyle(fontSize: 30)),
                      title: Text(food.name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${food.size} - ${food.calories} cal', style: TextStyle(color: Colors.grey)),
                          Text(food.subtitle),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _showQuantityDialog(context, food);
                        },
                        child: Text('Add'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.teal, // White text color
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Cart Section - This part is integrated directly into the Column
            if (showCart) // Show cart section only if there are items
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                width: MediaQuery.of(context).size.width * 0.95, // Adjust the width here
                height: 60, // Fixed height for the cart UI
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cart: ${addedFoodItems.length} items',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodSummaryScreen(
                              addedFoodItems: addedFoodItems,
                              mealPeriod: selectedMealPeriod,
                            ),
                          ),
                        );
                      },
                      child: Text('Finish'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blueAccent, backgroundColor: Colors.white, // Text color
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }}
