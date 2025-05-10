import 'package:flutter/material.dart';
import 'game_models.dart';

class FillGamePage extends StatefulWidget {
  final int? age;
  const FillGamePage({Key? key, this.age}) : super(key: key);

  @override
  _FillGamePageState createState() => _FillGamePageState();
}

class _FillGamePageState extends State<FillGamePage> {
  late List<FillGameQuestion> questions;
  int currentQuestionIndex = 0;
  String? selectedOption;
  bool hasAnswered = false;
  int score = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      if (widget.age != null && widget.age! >= 2 && widget.age! <= 20) {
        final loadedQuestions = await GameService.loadFillGameQuestions(
          widget.age!,
        );
        setState(() {
          questions = loadedQuestions;
          isLoading = false;
        });
      } else {
        setState(() {
          questions = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading questions: $e');
      setState(() {
        questions = [];
        isLoading = false;
      });
    }
  }

  void checkAnswer(String option) {
    if (hasAnswered) return;

    setState(() {
      selectedOption = option;
      hasAnswered = true;
      if (option == questions[currentQuestionIndex].answer) {
        score++;
      }
    });

    // Add a short delay before moving to next question if correct
    if (option == questions[currentQuestionIndex].answer) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          nextQuestion();
        }
      });
    }
  }

  void nextQuestion() {
    setState(() {
      selectedOption = null;
      hasAnswered = false;
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        // Show game completion dialog
        showGameCompletionDialog();
      }
    });
  }

  void showGameCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.red.shade200, width: 2),
          ),
          title: Text(
            'Game Complete!',
            style: TextStyle(color: Colors.red.shade700),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You scored $score out of ${questions.length}',
                style: TextStyle(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                _getScoreMessage(score, questions.length),
                style: TextStyle(color: Colors.red.shade400),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to game selection
              },
              child: Text('OK', style: TextStyle(color: Colors.red.shade600)),
            ),
          ],
        );
      },
    );
  }

  String _getScoreMessage(int score, int total) {
    final percentage = (score / total) * 100;
    if (percentage >= 80) {
      return 'Excellent! You\'re a word master! 🌟';
    } else if (percentage >= 60) {
      return 'Good job! Keep practicing! 👍';
    } else {
      return 'Keep trying, you\'ll get better! 💪';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fill in the Blanks'),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Text('No questions available for this age group.'),
        ),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill in the Blanks'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress and Score
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  backgroundColor: Colors.red.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${currentQuestionIndex + 1}/${questions.length}',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Score: $score',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Question
                Card(
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.red.shade200, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Options
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children:
                        question.options.map((option) {
                          final bool isSelected = selectedOption == option;
                          final bool isCorrect = option == question.answer;

                          Color backgroundColor;
                          if (hasAnswered) {
                            if (isSelected && isCorrect) {
                              backgroundColor = Colors.green;
                            } else if (isSelected && !isCorrect) {
                              backgroundColor = Colors.red;
                            } else if (isCorrect) {
                              backgroundColor = Colors.green.shade100;
                            } else {
                              backgroundColor = Colors.white;
                            }
                          } else {
                            backgroundColor =
                                isSelected ? Colors.red.shade100 : Colors.white;
                          }

                          return InkWell(
                            onTap:
                                hasAnswered ? null : () => checkAnswer(option),
                            child: Card(
                              elevation: 4,
                              color: backgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? Colors.red
                                          : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        hasAnswered && isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),

                // Explanation (visible after answering)
                if (hasAnswered)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      question.explanation,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Next button (visible after wrong answer)
                if (hasAnswered && selectedOption != question.answer)
                  ElevatedButton(
                    onPressed: nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      currentQuestionIndex < questions.length - 1
                          ? 'Next Question'
                          : 'Finish',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
