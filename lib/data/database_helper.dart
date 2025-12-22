import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mood_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  final _supabase = Supabase.instance.client;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('moods.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE moods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        emoji TEXT NOT NULL,
        note TEXT,
        imagePath TEXT
      )
    ''');
  }

  Future<int> createMood(MoodEntry mood) async {
    final db = await instance.database;
    final id = await db.insert('moods', mood.toMap());

    try {
      await _supabase.from('moods').insert(mood.toMap());
    } catch (e) {
      print("Supabase Sync Error: $e");
    }

    return id;
  }

  Future<List<MoodEntry>> readAllMoods() async {
    final db = await instance.database;
    final result = await db.query('moods', orderBy: 'date DESC');
    return result.map((json) => MoodEntry.fromMap(json)).toList();
  }

  Future<int> updateMood(MoodEntry mood) async {
    final db = await instance.database;
    final count = await db.update('moods', mood.toMap(), where: 'id = ?', whereArgs: [mood.id]);

    try {
      await _supabase.from('moods').update(mood.toMap()).eq('date', mood.date);
    } catch (e) {
      print("Supabase Sync Error: $e");
    }

    return count;
  }

  Future<int> deleteMood(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('moods', where: 'id = ?', whereArgs: [id]);
    final count = await db.delete('moods', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      try {
        await _supabase.from('moods').delete().eq('date', maps.first['date']);
      } catch (e) {
        print("Supabase Sync Error: $e");
      }
    }

    return count;
  }
}