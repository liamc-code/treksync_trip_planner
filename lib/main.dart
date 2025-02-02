/* main.dart
* TrekSync - Trip Planner
* Description - Main entry point into application, which
*               directs to first screen trip_form_screen.
*
*/

import 'package:flutter/material.dart';
import 'trip_form_screen.dart';
import 'dbhelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ensure fully initialized engine before running async
  await DatabaseHelper.instance.database; // Initialize the database
  runApp(const TripManagementApp());
}

class TripManagementApp extends StatelessWidget {
  const TripManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trip Management',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const TripFormScreen(),
    );
  }
}