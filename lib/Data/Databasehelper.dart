import 'dart:ffi';

import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'dart:math';

class DatabaseHelper {
  static Future<int?> getLenId(String lineName, String partyName) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'Lending',
      columns: ['LenId'],
      where: 'LineName = ? AND PartyName = ?',
      whereArgs: [lineName, partyName],
    );

    if (result.isNotEmpty) {
      return result.first['LenId'] as int?;
    } else {
      return null;
    }
  }

  static Future<String?> getStatus(int lenId) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'Lending',
      columns: ['status'],
      where: 'LenId = ?',
      whereArgs: [lenId],
    );

    if (result.isNotEmpty) {
      return result.first['status'] as String?;
    } else {
      return null;
    }
  }

  static Future<sql.Database> getDatabase() async {
    // Get the database path
    final dbPath = await sql.getDatabasesPath();

    // Open the database
    final db = await sql.openDatabase(
      path.join(dbPath, 'finance3.db'),
      version: 1,
      onCreate: (db, version) async {
        var batch = db.batch();

        // Create LineTable
        // ... rest of the code

// Create LineTable
        batch.execute('''
  CREATE TABLE Line (
    Linename TEXT PRIMARY KEY,
    Amtgiven REAL,
    Profit REAL,
    TotalAmt REAL,
    Amtrecieved REAL
  )
''');

// ... rest of the code

        // Create LendingTable
        await db.execute('''
      CREATE TABLE Lending (
           LenId INTEGER,
           LineName TEXT NOT NULL,
          PartyName TEXT NOT NULL,
          PartyAdd Text,
          PartyPhnone Text,
          amtgiven REAL NOT NULL,
          profit REAL,
          total REAL,
          Lentdate date,
    duedays INTEGER,
    duedate date,
    amtcollected REAL,
    DueAmt REAL,
    Daysrem INTEGER,
    status TEXT,
    PRIMARY KEY (LineName, PartyName)  
  )
''');

        // Create CollectionTable
        await db.execute('''
  CREATE TABLE Collection (
    LenId INTEGER NOT NULL,
    Date date NOT NULL,
    CrAmt REAL,
    DrAmt REAL
  )
''');

        await batch.commit();
      },
    );
    return db;
  }

  static Future<void> dropDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final pathToDb = path.join(dbPath, 'finance3.db');
    await sql.deleteDatabase(pathToDb);
  }
}

//LINE OPERATIONS

class dbline {
  static Future<Map<String, double>> allLineDetails() async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        SUM(Amtgiven) as totalAmtGiven, 
        SUM(Profit) as totalProfit, 
        SUM(Amtrecieved) as totalAmtRecieved 
      FROM Line
    ''');

    if (result.isNotEmpty) {
      return {
        'totalAmtGiven': result.first['totalAmtGiven'] as double? ?? 0.0,
        'totalProfit': result.first['totalProfit'] as double? ?? 0.0,
        'totalAmtRecieved': result.first['totalAmtRecieved'] as double? ?? 0.0,
      };
    } else {
      return {
        'totalAmtGiven': 0.0,
        'totalProfit': 0.0,
        'totalAmtRecieved': 0.0,
      };
    }
  }

  static Future<void> updateLine({
    required String lineName,
    required Map<String, dynamic> updatedValues,
  }) async {
    final db = await DatabaseHelper.getDatabase();

    // Update the existing entry
    await db.update(
      'Line',
      updatedValues,
      where: 'LOWER(Linename) = ?',
      whereArgs: [lineName.toLowerCase()],
    );
  }

  static Future<void> updateLineAmounts({
    required String lineName,
    required double amtGiven,
    required double profit,
    required double totalAmt,
  }) async {
    final db = await DatabaseHelper.getDatabase();

    // Update the existing entry
    await db.update(
      'Line',
      {
        'Amtgiven': amtGiven,
        'Profit': profit,
        'TotalAmt': totalAmt,
      },
      where: 'LOWER(Linename) = ?',
      whereArgs: [lineName.toLowerCase()],
    );
  }

  static Future<void> insertLine(String lineName) async {
    final db = await DatabaseHelper.getDatabase();

    // Check if the entry already exists (case-insensitive)
    final List<Map<String, dynamic>> existingEntries = await db.query(
      'Line',
      where: 'LOWER(Linename) = ?',
      whereArgs: [lineName.toLowerCase()],
    );

    if (existingEntries.isNotEmpty) {
      // Entry already exists
      throw Exception('Cannot insert: Line name already exists.');
    } else {
      // Insert the new entry
      await db.insert(
        'Line',
        {
          'Linename': lineName,
          'Amtgiven': 0.0,
          'Profit': 0.0,
          'TotalAmt': 0.0,
          'Amtrecieved': 0.0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<String>> getLineNames() async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('Line', columns: ['Linename']);

    return List.generate(maps.length, (i) {
      return maps[i]['Linename'] as String;
    });
  }
}

class dbLending {
  static Future<Map<String, double>> getLineSums(String lineName) async {
    final db = await DatabaseHelper.getDatabase();
    final result = await db.rawQuery('''
      SELECT 
        SUM(AmtGiven) as totalAmtGiven, 
        SUM(Profit) as totalProfit, 
        SUM(AmtCollected) as totalAmtCollected, 
        SUM(DueAmt) as totalDueAmt 
      FROM Lending
      WHERE LineName = ?
    ''', [lineName]);

    if (result.isNotEmpty) {
      return {
        'totalAmtGiven': result.first['totalAmtGiven'] as double? ?? 0.0,
        'totalProfit': result.first['totalProfit'] as double? ?? 0.0,
        'totalAmtCollected':
            result.first['totalAmtCollected'] as double? ?? 0.0,
        'totalDueAmt': result.first['totalDueAmt'] as double? ?? 0.0,
      };
    } else {
      return {
        'totalAmtGiven': 0.0,
        'totalProfit': 0.0,
        'totalAmtCollected': 0.0,
        'totalDueAmt': 0.0,
      };
    }
  }

  static Future<Map<String, dynamic>> getPartySums(int Lenid) async {
    final db = await DatabaseHelper.getDatabase();
    final result = await db.rawQuery('''
      SELECT 
        SUM(AmtGiven) as totalAmtGiven, 
        SUM(Profit) as totalProfit, 
        SUM(AmtCollected) as totalAmtCollected, 
        SUM(DueAmt) as totalDueAmt,
        MAX(DueDate) as dueDate,
        MIN(Daysrem) as daysRemaining
      FROM Lending
      WHERE LenId = ?
    ''', [Lenid]);

    if (result.isNotEmpty) {
      return {
        'totalAmtGiven': result.first['totalAmtGiven'] as double? ?? 0.0,
        'totalProfit': result.first['totalProfit'] as double? ?? 0.0,
        'totalAmtCollected':
            result.first['totalAmtCollected'] as double? ?? 0.0,
        'totalDueAmt': result.first['totalDueAmt'] as double? ?? 0.0,
        'dueDate': result.first['dueDate'] as String? ?? '',
        'daysRemaining': result.first['daysRemaining'] as int? ?? 0,
      };
    } else {
      return {
        'totalAmtGiven': 0.0,
        'totalProfit': 0.0,
        'totalAmtCollected': 0.0,
        'totalDueAmt': 0.0,
        'dueDate': '',
        'daysRemaining': 0,
      };
    }
  }

  static Future<void> updateDaysRem() async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> lendingEntries = await db.query(
      'Lending',
      where: 'status = ?',
      whereArgs: ['active'],
    );

    final DateTime today = DateTime.now();

    for (var entry in lendingEntries) {
      final String? lentDateStr = entry['Lentdate'] as String?;
      final String? dueDateStr = entry['duedate'] as String?;

      if (lentDateStr != null && dueDateStr != null) {
        final DateTime lentDate = DateTime.parse(lentDateStr);
        final DateTime dueDate = DateTime.parse(dueDateStr);

        final int daysRem = dueDate.difference(today).inDays + 1;

        await db.update(
          'Lending',
          {'Daysrem': daysRem},
          where: 'LenId = ?',
          whereArgs: [entry['LenId']],
        );
      }
    }
  }

  static Future<List<String>> getPartyNames(String lineName) async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'Lending',
      columns: ['PartyName'],
      where: 'LineName = ?',
      whereArgs: [lineName],
    );

    return List.generate(maps.length, (i) {
      return maps[i]['PartyName'] as String;
    });
  }

  static Future<void> insertParty({
    required String lineName,
    required String partyName,
    required String partyPhoneNumber,
    required String address,
    required int lenId,
  }) async {
    final db = await DatabaseHelper.getDatabase();

    // Check if the entry already exists
    final List<Map<String, dynamic>> existingEntries = await db.query(
      'Lending',
      where: 'LineName = ? AND PartyName = ?',
      whereArgs: [lineName, partyName],
    );

    if (existingEntries.isNotEmpty) {
      // Entry already exists
      throw Exception('Cannot insert: Party already exists for this line.');
    }

    // Check if the LenId already exists
    final List<Map<String, dynamic>> existingLenIdEntries = await db.query(
      'Lending',
      where: 'LenId = ?',
      whereArgs: [lenId],
    );

    if (existingLenIdEntries.isNotEmpty) {
      // LenId already exists
      throw Exception('Cannot insert: LenId already exists.');
    }

    // Insert the new entry
    await db.insert(
      'Lending',
      {
        'LenId': lenId,
        'LineName': lineName,
        'PartyName': partyName,
        'PartyPhnone': partyPhoneNumber,
        'PartyAdd': address,
        'amtgiven': 0.0,
        'profit': 0.0,
        'total': 0.0,
        'Lentdate': null,
        'duedays': 0,
        'duedate': null,
        'amtcollected': 0.0,
        'DueAmt': 0.0,
        'Daysrem': 0,
        'status': 'passive',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateDueAmt({
    required int lenId,
    required Map<String, dynamic> updatedValues,
  }) async {
    final db = await DatabaseHelper.getDatabase();

    // Update the entry
    await db.update(
      'Lending',
      updatedValues,
      where: 'LenId = ?',
      whereArgs: [lenId],
    );
  }

  static Future<void> updateLending({
    required String lineName,
    required String partyName,
    required int lenId,
    required Map<String, dynamic> updatedValues,
  }) async {
    final db = await DatabaseHelper.getDatabase();

    // Update the entry
    await db.update(
      'Lending',
      updatedValues,
      where: 'LineName = ? AND PartyName = ?',
      whereArgs: [lineName, partyName],
    );

    final lentDate = updatedValues['Lentdate'];
    final total = updatedValues['total'];
    print(lenId.toString());
    await db.insert(
      'Collection',
      {
        'LenId': lenId,
        'Date': lentDate,
        'CrAmt': total,
        'DrAmt': 0.0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

class CollectionDB {
  static Future<void> insertCollection({
    required int lenId,
    required String date,
    required double crAmt,
    required double drAmt,
  }) async {
    final db = await DatabaseHelper.getDatabase();

    await db.insert(
      'Collection',
      {
        'LenId': lenId,
        'Date': date,
        'CrAmt': crAmt,
        'DrAmt': drAmt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getCollectionEntries(
      int lenId) async {
    final db = await DatabaseHelper.getDatabase();
    return await db.query(
      'Collection',
      where: 'LenId = ?',
      whereArgs: [lenId],
      orderBy: 'Date DESC',
    );
  }
}
