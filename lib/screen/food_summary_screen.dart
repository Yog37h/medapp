// lib/screen/food_summary_screen.dart

import 'package:flutter/material.dart';
import '../model/model.dart';

class FoodSummaryScreen extends StatelessWidget {
  final Map<FoodItem, double> addedFoodItems;
  final String mealPeriod;

  FoodSummaryScreen({
    required this.addedFoodItems,
    required this.mealPeriod,
  });

  @override
  Widget build(BuildContext context) {
    double totalCalories = addedFoodItems.entries
        .map((entry) => entry.key.calories * entry.value)
        .reduce((value, element) => value + element);

    return Scaffold(
      appBar: AppBar(
        title: Text("Meal Summary"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Meal Period: $mealPeriod",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: addedFoodItems.length,
                itemBuilder: (context, index) {
                  final foodItem = addedFoodItems.keys.elementAt(index);
                  final quantity = addedFoodItems[foodItem]!;
                  return ListTile(
                    leading: Text(foodItem.logo, style: TextStyle(fontSize: 30)),
                    title: Text(foodItem.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Quantity: $quantity, Calories: ${foodItem.calories * quantity}"),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Total Calories: ${totalCalories.toStringAsFixed(1)}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Confirm"),
                style: ElevatedButton.styleFrom(

                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
