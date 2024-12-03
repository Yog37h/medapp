import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/screen/Payment_method.dart';


class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  Set<String> selectedItems = Set<String>();
  bool isLoading = true;
  String username = "";

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchCartItems();
  }

  Future<void> _fetchUsername() async {
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

  Future<void> _fetchCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Fetch the user's cart items from Firestore
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('checkoutitems')
            .get();

        // Map Firestore data to the local cartItems list
        setState(() {
          cartItems = snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              'name': doc['name'],
              'description': doc['description'],
              'cost': doc['cost'],
              'capacity': doc['capacity'],
            };
          }).toList();
          isLoading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load cart items!")),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _removeFromCart(String cartItemId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Remove the item from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('checkoutitems')
            .doc(cartItemId)
            .delete();

        setState(() {
          cartItems.removeWhere((item) => item['id'] == cartItemId);
          selectedItems.remove(cartItemId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Item removed from cart!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to remove item from cart!")),
        );
      }
    }
  }

  void _toggleSelection(String cartItemId) {
    setState(() {
      if (selectedItems.contains(cartItemId)) {
        selectedItems.remove(cartItemId);
      } else {
        selectedItems.add(cartItemId);
      }
    });
  }

  Future<void> _confirmPayment(List<Map<String, dynamic>> selected) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final orderData = {
        'userId': user.uid,
        'products': selected.map((item) => {
          'id': item['id'],
          'name': item['name'],
          'cost': item['cost'],
        }).toList(),
        'totalCost': selected.fold(0.0, (sum, item) => sum + (item['cost'] as num).toDouble()),
        'date': DateTime.now(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      try {
        // Add the order to the 'ordereditems' collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('ordereditems')
            .add(orderData);

        // Remove each paid item from the 'checkoutitems' collection and local cartItems list
        for (var item in selected) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('checkoutitems')
              .doc(item['id'])
              .delete();

          setState(() {
            cartItems.removeWhere((cartItem) => cartItem['id'] == item['id']);
          });
        }

        // Clear selected items
        setState(() {
          selectedItems.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order placed successfully and items removed from cart!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to place the order!")),
        );
      }
    }
  }

  void _showPaymentDialog() {
    final selected = cartItems.where((item) => selectedItems.contains(item['id'])).toList();
    final totalSum = selected.fold(0.0, (sum, item) => sum + (item['cost'] as num).toDouble());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Payment"),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Selected Medicines:"),
                SizedBox(height: 8),
                ...selected.map((item) => Text(item['name'])).toList(),
                SizedBox(height: 16),
                Text(
                  "Total Cost: ₹$totalSum",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Pay"),
              onPressed: () {
                // Call the existing payment confirmation function
                _confirmPayment(selected);

                // Navigate to the PaymentMethodScreen, passing the totalAmount
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentMethodScreen(totalAmount: totalSum),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
        title: Text('$username\'s Cart'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? Center(child: Text('Your cart is empty!'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: cartItems.map((cartItem) {
                    final isSelected = selectedItems.contains(cartItem['id']);
                    return GestureDetector(
                      onLongPress: () => _toggleSelection(cartItem['id']),
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          tileColor: isSelected
                              ? Colors.green.withOpacity(0.2)
                              : Colors.white,
                          title: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(cartItem['name']),
                              if (isSelected)
                                Icon(Icons.check_circle, color: Colors.green),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(cartItem['description']),
                              SizedBox(height: 4),
                              Text(cartItem['capacity']),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "₹${cartItem['cost']}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _removeFromCart(cartItem['id']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectedItems.isEmpty ? null : _showPaymentDialog,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(width: 15), // Adds space before the icon
                  Transform.rotate(
                    angle: 0, // Rotate the icon 30 degrees counterclockwise
                    child: Icon(Icons.monetization_on, color: Colors.black),
                  ),
                  SizedBox(width: 8),
                  Text('Proceed to Checkout'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                elevation: 10, // Adds shadow to the button
                shadowColor: Colors.grey.withOpacity(0.9), // Color of the shadow
              ),
            ),
          ],
        ),
      ),
    );
  }
}