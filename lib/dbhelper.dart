/* dbhelper.dart
* TrekSync - Trip Planner
* Description - Class to interface with Db to create db, tables,
*               clear out old db, and interface CRUD methods
*               for use in trip_list_screen and trip_detail_screen.
*
*/

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('trips.db');
    return _database!;
  }

  // Initialize the database at the specified file path.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Increment version
      onCreate: _createDB, // Create schema
      onUpgrade: _upgradeDB, // Handle upgrades
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create the trips table with the required schema
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
    CREATE TABLE trips (
      id $idType,
      customerType $textType,
      destination $textType,
      contactPhone $textType,
      emailAddress $textType,
      tripPrice $doubleType,
      additionalInfo1 TEXT,
      additionalInfo2 TEXT
    )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Upgrade the database schema for new versions
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE trips ADD COLUMN destination TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE trips ADD COLUMN contactPhone TEXT');
    }
  }

  Future<int> createTrip(Map<String, dynamic> trip) async {
    // Insert a new trip record into the database
    final db = await instance.database;
    return await db.insert('trips', trip);
  }

  Future<List<Map<String, dynamic>>> readAllTrips() async {
    // Retrieve all trips from the database
    final db = await instance.database;
    return await db.query('trips');
  }

  Future<int> updateTrip(int id, Map<String, dynamic> trip) async {
    // Update an existing trip record by ID
    final db = await instance.database;
    return await db.update('trips', trip, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTrip(int id) async {
    // Delete a trip record by ID
    final db = await instance.database;
    return await db.delete('trips', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    // Close the database connection
    final db = await instance.database;
    db.close();
  }
}