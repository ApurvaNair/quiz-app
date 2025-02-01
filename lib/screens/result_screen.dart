import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'home_screen.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key, required int score});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    // Score thresholds for special effects (gamification)
    const int milestone = 100;

    // List to hold answers and categories for summary
    final summary = quizProvider.questions.map((question) {
      return "Q: ${question.question}\nA: ${question.correctAnswer}\n";
    }).join("\n\n");

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50, // Light background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Animated Score Display
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 800),
                child: Text(
                  "Your Score: ${quizProvider.score} XP",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: quizProvider.score >= milestone
                        ? Colors.orangeAccent
                        : Colors.green,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Streak message with fade-in effect
              if (quizProvider.streak > 0)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 1000),
                  child: Text(
                    "🔥 Streak: ${quizProvider.streak} Correct Answers in a Row!",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // Play Again button with enhanced design
              ElevatedButton(
                onPressed: () {
                  quizProvider.resetQuiz();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadowColor: Colors.black.withOpacity(0.3),
                  elevation: 8,
                ),
                child: const Text(
                  "Play Again",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 30),

              // Answer Summary Section with Better Visibility
              if (quizProvider.questions.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(
                            146, 188, 208, 1), // More visible background
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "📖 Answer Summary",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 21, 49, 62),
                            ),
                          ),
                          const Divider(thickness: 1),
                          const SizedBox(height: 10),
                          Text(
                            summary,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                              fontWeight:
                                  FontWeight.w500, // Increased readability
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
