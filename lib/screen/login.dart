import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/data/auth_data.dart';
import 'package:flutter_to_do_list/screen/home.dart'; // Import the home screen
import 'package:lottie/lottie.dart'; // Import Lottie package
import 'package:animated_text_kit/animated_text_kit.dart'; // Import animated text package
import 'package:firebase_auth/firebase_auth.dart'; // Firebase auth

class LogIN_Screen extends StatefulWidget {
  final VoidCallback showSignUp;
  LogIN_Screen({required this.showSignUp, super.key});

  @override
  State<LogIN_Screen> createState() => _LogIN_ScreenState();
}

class _LogIN_ScreenState extends State<LogIN_Screen> {
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();

  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(() {
      setState(() {}); // Trigger rebuild when focus changes
    });
    _focusNode2.addListener(() {
      setState(() {}); // Trigger rebuild when focus changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal, // Updated background color
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              lottieAnimation(), // Lottie animation
              SizedBox(height: 20),
              glowingText(), // Glowing text
              SizedBox(height: 50),
              textfield(email, _focusNode1, 'Email', Icons.email),
              SizedBox(height: 10),
              textfield(password, _focusNode2, 'Password', Icons.lock),
              SizedBox(height: 8),
              account(),
              SizedBox(height: 20),
              Login_bottom(),
            ],
          ),
        ),
      ),
    );
  }

  Widget account() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Don't have an account?",
            style: TextStyle(color: Colors.grey[300], fontSize: 14),
          ),
          SizedBox(width: 5),
          GestureDetector(
            onTap: widget.showSignUp,
            child: Text(
              'Sign up',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // Function to store login history in Firestore
  Future<void> _storeLoginHistory(String userId) async {
    try {
      // Get today's date in a readable format (e.g., "2024-10-08")
      DateTime now = DateTime.now();
      String formattedDate = "${now.year}-${now.month}-${now.day}";

      // Reference to the user's login history collection in Firestore
      DocumentReference userLoginDoc = FirebaseFirestore.instance
          .collection('loginHistory')
          .doc(userId)
          .collection('logins')
          .doc(formattedDate); // Document for the specific date

      // Check if a login entry for today already exists
      DocumentSnapshot docSnapshot = await userLoginDoc.get();

      if (docSnapshot.exists) {
        // If it exists, update the login count (increment by 1)
        await userLoginDoc.update({
          'loginCount': FieldValue.increment(1),
        });
      } else {
        // If it doesn't exist, create a new entry for today with loginCount = 1
        await userLoginDoc.set({
          'loginCount': 1,
          'date': formattedDate,
        });
      }
    } catch (e) {
      print('Error storing login history: $e');
    }
  }

  Widget Login_bottom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: () async {
          // Handle user login
          bool isSuccess = await AuthenticationRemote().login(email.text, password.text);
          if (isSuccess) {
            // Retrieve the logged-in user's UID
            User? user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              // Store the login history for the logged-in user
              await _storeLoginHistory(user.uid);

              // Navigate to the home screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home_Screen()),
              );
            }
          } else {
            // Handle login failure (e.g., show a snackbar)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login failed. Please try again.')),
            );
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black], // Gradient background
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget textfield(TextEditingController _controller, FocusNode _focusNode,
      String typeName, IconData iconss) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: TextStyle(fontSize: 18, color: Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(
              iconss,
              color: _focusNode.hasFocus ? Colors.black : Colors.grey,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            hintText: typeName,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Color(0xffc5c5c5),
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.black,
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget lottieAnimation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: double.infinity,
        height: 300, // Adjust height if needed
        child: Lottie.asset('images/assets/mylottie.json'), // Load your Lottie animation
      ),
    );
  }

  Widget glowingText() {
    return Column(
      children: [
        SizedBox(height: 20),
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 50.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.tealAccent,
                blurRadius: 10.0,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: AnimatedTextKit(
            isRepeatingAnimation: true,
            animatedTexts: [
              TyperAnimatedText('EZMED', speed: Duration(milliseconds: 100)),
            ],
          ),
        ),
        SizedBox(height: 10),
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.tealAccent,
                blurRadius: 10.0,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: AnimatedTextKit(
            isRepeatingAnimation: true,
            animatedTexts: [
              TyperAnimatedText('Digitalized Medication', speed: Duration(milliseconds: 100)),
            ],
          ),
        ),
      ],
    );
  }
}
