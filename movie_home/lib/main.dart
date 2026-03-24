import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:movie_home/homepage/login.dart';
import 'package:movie_home/homepage/movie_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  final prefs = await SharedPreferences.getInstance();
  final loggedIn = prefs.getBool('loggedIn') ?? false;

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cinema Booking App',
      home: loggedIn ? const MovieListPage() : const LoginPage(),
    );
  }
}