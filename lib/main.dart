
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_to_do_list/screen/SingUP.dart';
import 'package:flutter_to_do_list/screen/home_screen.dart';
import 'package:flutter_to_do_list/screen/login.dart';
import 'package:flutter_to_do_list/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'flutter_to_do_list',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use a condition to check if the user is logged in or not
    // For example:
    bool isLoggedIn = false; // Replace with your auth check logic

    if (isLoggedIn) {
      return HomeScreen();
    } else {
      return LogIN_Screen(showSignUp: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUp_Screen(showLogin: () {
            Navigator.pop(context);
          })),
        );
      });
    }
  }
}
