import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/mood_model.dart';

class MoodController extends ChangeNotifier {
  List<MoodEntry> _moods = [];
  List<MoodEntry> get moods => _moods;

  Future<void> loadMoods() async {
    // Only looks at your local SQLite file now
    _moods = await DatabaseHelper.instance.readAllMoods();
    notifyListeners();
  }

  Future<void> addMood(MoodEntry entry) async {
    await DatabaseHelper.instance.createMood(entry);
    await loadMoods();
  }

  Future<void> updateMood(MoodEntry entry) async {
    await DatabaseHelper.instance.updateMood(entry);
    await loadMoods();
  }

  Future<void> deleteMood(int id) async {
    await DatabaseHelper.instance.deleteMood(id);
    await loadMoods();
  }

  Map<String, double> getWeeklyPercentages() {
    if (_moods.isEmpty) return {};
    // Use the 7 most recent records for the chart
    final recent = _moods.length > 7 ? _moods.sublist(0, 7) : _moods;
    Map<String, int> counts = {};
    for (var m in recent) {
      counts[m.emoji] = (counts[m.emoji] ?? 0) + 1;
    }
    return counts.map((key, val) => MapEntry(key, (val / recent.length) * 100));
  }

  String getDynamicEncouragement() {
    if (_moods.isEmpty) return "Start tracking to see insights!";
    String mood = _moods.first.emoji;
    if (['🤩', '😊'].contains(mood)) return "Keep shining! Your energy is great. ✨";
    if (['😔', '😡'].contains(mood)) return "It's okay to feel this way. Take a breath. 🌿";
    return "Every day is a new start. Keep going! 📖";
  }
}