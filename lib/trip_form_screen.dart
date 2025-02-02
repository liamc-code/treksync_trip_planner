/* trip_form_screen.dart
* TrekSync - Trip Planner
* Description - Home/Start screen of app to proceed to trip_list_screen
*               for creation/display/modification of trip entries.
*
*/

import 'package:flutter/material.dart';
import 'trip_list_screen.dart';

class TripFormScreen extends StatelessWidget {
  const TripFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('TrekSync - Trip Planner'),
            SizedBox(width: 8),
            Icon(Icons.travel_explore),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                // main heading of home app screen
                'Welcome to TrekSync Trip Planner',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                // desc of app functionality 
                'Manage all your trips effectively. Add, edit, or view details about your trips.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // navigate to TripListScreen to view/edit trip entries
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TripListScreen(),
                    ),
                  );
                },
                child: const Text('Go to Trip List'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}