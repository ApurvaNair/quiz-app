import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';

class QuizProvider with ChangeNotifier {
  List<Question> _questions = [];
  int _score = 0;
  int _streak = 0;
  int _xp = 0; // New XP attribute
  int _level = 1; // New Level attribute
  bool _isLoading = true;
  String? _errorMessage;

  List<Question> get questions => _questions;
  int get score => _score;
  int get streak => _streak;
  int get xp => _xp; // Expose XP
  int get level => _level; // Expose Level
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ✅ Use a working API (Replace this with your actual API)
  final String apiUrl = "https://api.jsonserve.com/Uw5CrX";

  Future<void> loadQuestions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(
          const Duration(seconds: 5)); // Timeout to prevent infinite wait

      print("📥 RAW API Response: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("📌 Parsed Data: $data"); // Debugging

        if (data is Map<String, dynamic>) {
          if (data.containsKey('questions')) {
            final results = data['questions'];
            print("🔎 API Results: $results"); // Check if 'results' is a list

            if (results is List) {
              _questions = results.map((e) {
                print("🔎 Parsed Question: $e"); // Debugging each question data
                return Question.fromJson(e as Map<String, dynamic>);
              }).toList();
              print("✅ Questions Loaded: ${_questions.length}");
            } else {
              _errorMessage = "Results is not a list as expected.";
              _questions = [];
            }
          } else {
            _errorMessage = "API response missing 'results' key.";
            _questions = [];
          }
        } else {
          _errorMessage = "Unexpected API response format";
          _questions = [];
        }
      } else {
        _errorMessage =
            "Failed to fetch questions (Status: ${response.statusCode})";
        _questions = [];
      }
    } catch (e) {
      print("❌ Error fetching questions: $e");
      _errorMessage =
          "Failed to load questions. Please check your internet connection.";
      _questions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void increaseScore() {
    _score += 10;
    _streak++;
    _gainXP(20); // Award 20 XP for correct answers
    _checkLevelUp(); // Check if player leveled up
    _saveData();
    notifyListeners();
  }

  void resetStreak() {
    _streak = 0;
    _saveData();
    notifyListeners();
  }

  void resetQuiz() {
    _score = 0;
    _streak = 0;
    _xp = 0; // Reset XP
    _level = 1; // Reset Level
    _saveData();
    notifyListeners();
  }

  // Increase XP when correct answer is given
  void _gainXP(int points) {
    _xp += points;
    _checkLevelUp(); // Level up if XP threshold is reached
  }

  // Check if the player has leveled up
  void _checkLevelUp() {
    if (_xp >= 100 * _level) {
      // Level up after 100 * level XP
      _level++;
      _xp = 0; // Reset XP after level up
      notifyListeners();
    }
  }

  // Save score, streak, XP, and level to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('score', _score);
    await prefs.setInt('streak', _streak);
    await prefs.setInt('xp', _xp); // Save XP
    await prefs.setInt('level', _level); // Save Level
  }

  // Load saved score, streak, XP, and level from SharedPreferences
  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _score = prefs.getInt('score') ?? 0;
    _streak = prefs.getInt('streak') ?? 0;
    _xp = prefs.getInt('xp') ?? 0; // Load XP
    _level = prefs.getInt('level') ?? 1; // Load Level
    notifyListeners();
  }

  // Power-up: Skip a question (For example)
  void useSkipPowerUp() {
    // Example power-up logic
    _streak = 0; // Reset streak when power-up is used
    notifyListeners();
  }
}
