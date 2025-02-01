import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'result_screen.dart';
import 'dart:async'; // Import Timer

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedAnswer;
  String? _correctAnswer;
  bool _isAnswerSelected = false;
  bool _isAnswerCorrect = false;
  int _score = 0;
  int _streak = 0;
  late int _timer;
  late DateTime _timerStart;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      await Provider.of<QuizProvider>(context, listen: false).loadQuestions();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _timer = 30; // Set timer to 30 seconds for each question
          _timerStart = DateTime.now();
        });
        _startTimer();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Error loading questions. Please try again.";
        });
      }
    }
  }

  // Timer logic to countdown and move to the next question
  void _startTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timer > 0) {
        setState(() {
          _timer--;
        });
      } else {
        timer.cancel();
        _moveToNextQuestion(); // Move to the next question when time runs out
      }
    });
  }

  void _checkAnswer(String selectedAnswer) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final currentQuestion = quizProvider.questions[_currentIndex];

    setState(() {
      _selectedAnswer = selectedAnswer;
      _correctAnswer = currentQuestion.correctAnswer;
      _isAnswerSelected = true;
      _isAnswerCorrect = selectedAnswer == currentQuestion.correctAnswer;
      if (_isAnswerCorrect) {
        _score++;
        _streak++;
      } else {
        _streak = 0;
      }
    });

    if (!_isAnswerCorrect) {
      quizProvider.resetStreak(); // Reset streak for incorrect answer
    } else {
      quizProvider.increaseScore(); // Increase score for correct answer
    }

    // Delay before moving to the next question or showing results
    Future.delayed(const Duration(seconds: 1), () {
      _moveToNextQuestion();
    });
  }

  void _moveToNextQuestion() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    if (_currentIndex < quizProvider.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswerSelected = false;
        _timer = 30; // Reset timer for the next question
        _timerStart = DateTime.now();
      });
      _startTimer();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ScoreScreen(score: _score)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadQuestions();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (quizProvider.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No questions available.")),
      );
    }

    final currentQuestion = quizProvider.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz: Question ${_currentIndex + 1}"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
        elevation: 5,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.eco),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timer Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score: $_score',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Time: $_timer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Question Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  currentQuestion.question,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Options
              ...currentQuestion.options.map((option) {
                bool isSelected = _selectedAnswer == option;
                bool isCorrect =
                    option == currentQuestion.correctAnswer && isSelected;
                bool isWrong =
                    option != currentQuestion.correctAnswer && isSelected;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                isCorrect
                                    ? Colors.green.shade300
                                    : Colors.red.shade300,
                                isCorrect
                                    ? Colors.green.shade500
                                    : Colors.red.shade500
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                Colors.blueAccent.shade100,
                                Colors.blueAccent.shade700
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                    ),
                    child: ElevatedButton(
                      onPressed:
                          _isAnswerSelected ? null : () => _checkAnswer(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              if (_isAnswerSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _isAnswerCorrect
                        ? "Great job! ✅ You got it right."
                        : "Oops! ❌ The correct answer is: $_correctAnswer",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isAnswerCorrect
                          ? Colors.green.shade800
                          : Colors.red.shade700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.green.shade100,
    );
  }
}
