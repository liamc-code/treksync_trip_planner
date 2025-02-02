/* trip_list_screen.dart
* TrekSync - Trip Planner
* Description - This file displays all trip entries added to the DB in list form
*               allows for modification/deletion, add new trip, and display total
*               price.
*
*/

import 'package:flutter/material.dart';
import 'dbhelper.dart';
import 'trip_detail_screen.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  // list to store retrieved entries from db 
  late List<Map<String, dynamic>> _trips = [];
  // hold price of total trips retrieved from db
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }
  // get trips from db and recalculate total of trips to-date
  Future<void> _fetchTrips() async {
    // get all trip entries from db
    final trips = await DatabaseHelper.instance.readAllTrips();
    setState(() {
      _trips = trips;
      // gets trip prices and calcs the sum of trips
      _totalPrice = trips.fold(0.0, (sum, trip) => sum + (trip['tripPrice'] as double));
    });
  }
  // delete trip from db and thus ListView
  Future<void> _deleteTrip(int id) async {
    await DatabaseHelper.instance.deleteTrip(id);
    await _fetchTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('TrekSync - Trip List'),
            SizedBox(width: 8),
            Icon(Icons.travel_explore),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              // display total price from trip entries in db
              'Total Price: \$${_totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline
                ),
            ),
            const SizedBox(height: 10),
            Expanded(
              // display all trip entries in db
              child: ListView.builder(
                itemCount: _trips.length,
                itemBuilder: (context, index) {
                  final trip = _trips[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2), // Space between entries
                    padding: const EdgeInsets.all(8), // Inner padding for the container
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      borderRadius: BorderRadius.circular(40), // Rounded corners
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(128, 128, 128, 0.5), // Shadow color
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 2), // Shadow position
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade300), // Border color
                    ),
                    child: ListTile(
                      // trip title (destination)
                      title: Text(
                        trip['destination'] ?? 'No Destination',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, // bold title
                        )
                      ),
                      subtitle: Text(
                        // trip subtitle (additionalInfo based on customerType)
                        trip['customerType'] == 'Individual'
                            ? 'Home Address: ${trip['additionalInfo1'] ?? "N/A"}'
                            : trip['customerType'] == 'Family'
                                ? 'Family Member: ${trip['additionalInfo1'] ?? "N/A"}, Insurance: ${trip['additionalInfo2'] ?? "N/A"}'
                                : 'Company: ${trip['additionalInfo1'] ?? "N/A"}, Policy: ${trip['additionalInfo2'] ?? "N/A"}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            // edit trip entry button
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  // navigate to DetailScreen to edit
                                  builder: (context) => DetailScreen(
                                    trip: trip,
                                    isEditing: true,
                                  ),
                                ),
                              );
                              await _fetchTrips();
                            },
                          ),
                          IconButton(
                            // delete trip entry button and in db
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteTrip(trip['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              // add trip button and navigates to DetailScreen
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DetailScreen()),
                );
                await _fetchTrips();
              },
              style: ElevatedButton.styleFrom(
                elevation: 5.0 // slight shadow
              ),
              child: const Text('Add Trip'),
            ),
          ],
        ),
      ),
    );
  }
}