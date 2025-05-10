import 'package:flutter/material.dart';
import 'game_models.dart';

class SentenceGamePage extends StatefulWidget {
  final int? age;
  const SentenceGamePage({Key? key, this.age}) : super(key: key);

  @override
  _SentenceGamePageState createState() => _SentenceGamePageState();
}

class _SentenceGamePageState extends State<SentenceGamePage> {
  late List<SentenceGameQuestion> questions;
  int currentQuestionIndex = 0;
  List<String> selectedWords = [];
  List<String> availableWords = [];
  bool hasAnswered = false;
  bool isCorrect = false;
  bool isLoading = true;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      if (widget.age != null && widget.age! >= 2 && widget.age! <= 20) {
        // Load sentence questions for appropriate age group
        final loadedQuestions = await GameService.loadSentenceGameQuestions(
          widget.age!,
        );
        setState(() {
          questions = loadedQuestions;
          isLoading = false;
          if (questions.isNotEmpty) {
            _resetWords();
          }
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

  void _resetWords() {
    setState(() {
      selectedWords = [];
      availableWords = List.from(questions[currentQuestionIndex].options);
      availableWords.shuffle(); // Shuffle words for more challenge
    });
  }

  void _addWord(String word) {
    setState(() {
      selectedWords.add(word);
      availableWords.remove(word);
    });
  }

  void _removeWord(int index) {
    setState(() {
      availableWords.add(selectedWords[index]);
      selectedWords.removeAt(index);
    });
  }

  void _checkAnswer() {
    final sentence = selectedWords.join(' ');
    final isCorrect = sentence == questions[currentQuestionIndex].answer;

    setState(() {
      this.isCorrect = isCorrect;
      hasAnswered = true;
      if (isCorrect) {
        score++;
      }
    });

    // Add a short delay before moving to next question if correct
    if (isCorrect) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          nextQuestion();
        }
      });
    }
  }

  void nextQuestion() {
    setState(() {
      hasAnswered = false;
      isCorrect = false;
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        _resetWords();
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
      return 'Amazing! You are a sentence master! 🌟';
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
          title: const Text('Sentence Building'),
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
        title: const Text('Sentence Building'),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.red.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Question ${currentQuestionIndex + 1}/${questions.length}',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Score
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Question text
              Text(
                question.question,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Selected words area (your sentence)
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 4,
                  color:
                      hasAnswered
                          ? (isCorrect
                              ? Colors.green.shade50
                              : Colors.red.shade50)
                          : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color:
                          hasAnswered
                              ? (isCorrect ? Colors.green : Colors.red)
                              : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Sentence:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child:
                              selectedWords.isEmpty
                                  ? Center(
                                    child: Text(
                                      'Tap on words below to build your sentence',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )
                                  : Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: List.generate(
                                      selectedWords.length,
                                      (index) => InkWell(
                                        onTap:
                                            hasAnswered
                                                ? null
                                                : () => _removeWord(index),
                                        child: Chip(
                                          label: Text(
                                            selectedWords[index],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor:
                                              hasAnswered
                                                  ? (isCorrect
                                                      ? Colors.green.shade100
                                                      : Colors.red.shade100)
                                                  : Colors.red.shade100,
                                          deleteIcon:
                                              hasAnswered
                                                  ? null
                                                  : const Icon(
                                                    Icons.close,
                                                    size: 16,
                                                  ),
                                          onDeleted:
                                              hasAnswered
                                                  ? null
                                                  : () => _removeWord(index),
                                        ),
                                      ),
                                    ),
                                  ),
                        ),
                        if (hasAnswered)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              isCorrect
                                  ? 'Correct!'
                                  : 'Incorrect. The correct sentence is: ${question.answer}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Available words
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Words:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child:
                          availableWords.isEmpty
                              ? Center(
                                child: Text(
                                  'All words have been used',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                              : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children:
                                    availableWords.map((word) {
                                      return InkWell(
                                        onTap:
                                            hasAnswered
                                                ? null
                                                : () => _addWord(word),
                                        child: Chip(
                                          label: Text(
                                            word,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor: Colors.grey.shade100,
                                        ),
                                      );
                                    }).toList(),
                              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Check and Next buttons
              if (!hasAnswered)
                ElevatedButton(
                  onPressed: selectedWords.isNotEmpty ? _checkAnswer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Check Answer',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              if (hasAnswered)
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
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
