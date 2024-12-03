// lib/screen/StarScreen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StarScreen extends StatefulWidget {
  @override
  _StarScreenState createState() => _StarScreenState();
}

class _StarScreenState extends State<StarScreen> {
  List<Map<String, dynamic>> favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _fetchFavoriteItems();
  }

  void _fetchFavoriteItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      setState(() {
        favoriteItems = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    }
  }

  void _removeFromFavorites(String itemId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(itemId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Item removed from favorites!")),
        );

        // Update the UI
        setState(() {
          favoriteItems.removeWhere((item) => item['id'] == itemId);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to remove item from favorites!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Favorites'),
        backgroundColor: Colors.teal,
      ),
      body: favoriteItems.isEmpty
          ? Center(
        child: Text(
          "No items in favorites.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: favoriteItems.length,
        itemBuilder: (context, index) {
          final item = favoriteItems[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              title: Text(item['name'] ?? 'Unnamed Item'),
              subtitle: Text(item['description'] ?? 'No description'),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.grey),
                onPressed: () {
                  if (item['id'] != null) {
                    _removeFromFavorites(item['id']);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
