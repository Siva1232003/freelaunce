import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_page.dart'; // Ensure this file exists and is correctly named
import 'home_page.dart'; // Ensure this file exists and is correctly named
import 'welcome_page.dart'; // Ensure this file exists and is correctly named

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rich Printers',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', 
      routes: {
        '/': (context) => WelcomePage(),
        '/auth': (context) => SignInSignUpPage(), // Authentication page
        '/home': (context) =>  HomePage(), // Home page
      },
    );
  }
}
