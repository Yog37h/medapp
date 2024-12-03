import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../widgets/ProfilePage.dart';
import '../widgets/MedicinesPage.dart';
import '../widgets/SearchPage.dart';
import '../widgets/CartPage.dart';
import '../widgets/HomePage.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SearchPage(),
    CartPage(),
    MedicalEquipmentPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Set background color to blueGrey
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Medical Bot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'My Med',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Equipments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal, // Selected icon color to blue
        unselectedItemColor: Colors.blueGrey, // Unselected icon color to grey
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all icons show even with unselected items
        selectedLabelStyle: TextStyle(color: Colors.blue), // Selected text color to blue
        unselectedLabelStyle: TextStyle(color: Colors.grey), // Unselected text color to grey
      ),
    );
  }
}