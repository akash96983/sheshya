import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'game_models.dart';

class AudioGamePage extends StatefulWidget {
  final int? age;
  const AudioGamePage({Key? key, this.age}) : super(key: key);

  @override
  _AudioGamePageState createState() => _AudioGamePageState();
}

class _AudioGamePageState extends State<AudioGamePage> {
  late List<AudioGameQuestion> questions;
  int currentQuestionIndex = 0;
  String? selectedOption;
  bool hasAnswered = false;
  int score = 0;
  bool isLoading = true;
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playAudio() async {
    if (isPlaying) {
      await audioPlayer.stop();
      setState(() {
        isPlaying = false;
      });
    } else {
      try {
        setState(() {
          isPlaying = true;
        });
        await audioPlayer.setAsset(
          'assets/audio/${questions[currentQuestionIndex].audioFile}',
        );
        await audioPlayer.play();
      } catch (e) {
        print('Error playing audio: $e');
        setState(() {
          isPlaying = false;
        });
      }
    }
  }

  Future<void> _loadQuestions() async {
    try {
      if (widget.age != null && widget.age! >= 2 && widget.age! <= 20) {
        // Load audio questions for appropriate age group
        final loadedQuestions = await GameService.loadAudioGameQuestions(
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
    audioPlayer.stop();
    setState(() {
      selectedOption = null;
      hasAnswered = false;
      isPlaying = false;
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
      return 'Excellent! You have a great ear! 🎵';
    } else if (percentage >= 60) {
      return 'Good job! Keep listening! 👂';
    } else {
      return 'Keep practicing! You\'ll get better! 💪';
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
          title: const Text('Audio Game'),
          backgroundColor: Colors.green,
        ),
        body: const Center(
          child: Text('No questions available for this age group.'),
        ),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Quiz'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
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
                backgroundColor: Colors.green.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}/${questions.length}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Score: $score',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Audio player
              Expanded(
                flex: 2,
                child: Center(
                  child: InkWell(
                    onTap: playAudio,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isPlaying ? 70 : 80,
                          height: isPlaying ? 70 : 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isPlaying
                                    ? Colors.green.shade300
                                    : Colors.green,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Options
              Expanded(
                flex: 3,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    String option = question.options[index];
                    final bool isSelected = selectedOption == option;
                    final bool isCorrect = option == question.answer;

                    Color backgroundColor;
                    if (hasAnswered) {
                      if (isSelected && isCorrect) {
                        backgroundColor = Colors.green;
                      } else if (isSelected && !isCorrect) {
                        backgroundColor = Colors.red;
                      } else if (isCorrect) {
                        backgroundColor = Colors.green.shade200;
                      } else {
                        backgroundColor = Colors.white;
                      }
                    } else {
                      backgroundColor =
                          isSelected ? Colors.green.shade300 : Colors.white;
                    }

                    return InkWell(
                      onTap: hasAnswered ? null : () => checkAnswer(option),
                      child: Card(
                        margin: const EdgeInsets.all(3),
                        elevation: 2,
                        color: backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? Colors.green
                                    : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color:
                                    hasAnswered && isSelected
                                        ? Colors.white
                                        : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Next button (visible after answering)
              if (hasAnswered)
                ElevatedButton(
                  onPressed: nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
