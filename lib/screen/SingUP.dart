import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_to_do_list/screen/home.dart';
import 'package:flutter_to_do_list/data/auth_data.dart';
import 'package:lottie/lottie.dart';

class SignUp_Screen extends StatefulWidget {
  final VoidCallback showLogin;

  SignUp_Screen({required this.showLogin, super.key});

  @override
  State<SignUp_Screen> createState() => _SignUp_ScreenState();
}

class _SignUp_ScreenState extends State<SignUp_Screen> {
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode3 = FocusNode();
  FocusNode _focusNode4 = FocusNode();
  FocusNode _focusNode5 = FocusNode();

  final email = TextEditingController();
  final password = TextEditingController();
  final passwordConfirm = TextEditingController();
  final username = TextEditingController();
  final phoneNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(() {
      setState(() {});
    });
    _focusNode2.addListener(() {
      setState(() {});
    });
    _focusNode3.addListener(() {
      setState(() {});
    });
    _focusNode4.addListener(() {
      setState(() {});
    });
    _focusNode5.addListener(() {
      setState(() {});
    });
  }

  Future<void> signUp() async {
    if (password.text != passwordConfirm.text) {
      print('Passwords do not match');
      return;
    }

    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      User? user = userCredential.user;

      // Send verification email
      await user?.sendEmailVerification();

      // Store user details in Firestore after successful sign-up
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'username': username.text.trim(),
        'email': email.text.trim(),
        'phoneNumber': phoneNumber.text.trim(),
        'password': password.text.trim(),
      });

      _showEmailVerificationDialog();

    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
    }
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Verify your email'),
          content: Text('A verification link has been sent to ${email.text}. Please check your inbox.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.showLogin(); // After email verification, redirect to login
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // Reload user to get the latest status

    if (user?.emailVerified ?? false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home_Screen()),
      );
    } else {
      print("Email not verified yet.");
      _showEmailVerificationDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal, // Changed background color to teal
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Padding around the entire screen
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Lottie.asset(
                        'images/assets/mylottie.json', // Add your Lottie animation file path here
                        width: 200,
                        height: 200,
                      ),




                SizedBox(height: 30),
                Text(
                  "Create your account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Changed text color to white
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                textfield(username, _focusNode4, 'Username', Icons.person),
                SizedBox(height: 12),
                textfield(email, _focusNode1, 'Email', Icons.email),
                SizedBox(height: 12),
                textfield(phoneNumber, _focusNode5, 'Phone Number', Icons.phone),
                SizedBox(height: 12),
                textfield(password, _focusNode2, 'Password', Icons.lock),
                SizedBox(height: 12),
                textfield(passwordConfirm, _focusNode3, 'Confirm Password', Icons.lock),
                SizedBox(height: 16),
                Center(child: account()),
                SizedBox(height: 20),
                Center(child: SignUP_bottom()),
              ],
            ),
          ),
        ]),
      ),
    )));
  }

  Widget SignUP_bottom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: () async {
          await signUp(); // Trigger sign-up and email verification
        },
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black, // Changed button color to blue accent
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Text(
            'Sign up',
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
              color: Colors.black26,
              blurRadius: 4.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: TextStyle(fontSize: 18, color: Colors.grey),
          decoration: InputDecoration(
              prefixIcon: Icon(
                iconss,
                color: _focusNode.hasFocus ? Colors.black : Color(0xff5d6973), // Change icon color based on focus
              ),
              contentPadding:
              EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              hintText: typeName,
              hintStyle: TextStyle(color: Colors.grey[500]), // Hint text color
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2.0,
                ),
              )),
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
          Text("Already have an account?",
              style: TextStyle(color: Colors.white)), // Changed text color to white
          GestureDetector(
            onTap: widget.showLogin,
            child: Text(
              " Sign in",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
