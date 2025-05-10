import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class ImageMatchQuestion {
  final String image;
  final String correct;
  final List<String> options;

  ImageMatchQuestion({
    required this.image,
    required this.correct,
    required this.options,
  });

  factory ImageMatchQuestion.fromJson(Map<String, dynamic> json) {
    return ImageMatchQuestion(
      image: json['image'] as String,
      correct: json['correct'] as String,
      options: List<String>.from(json['options'] as List),
    );
  }
}

class FillGameQuestion {
  final String id;
  final String type;
  final String question;
  final List<String> options;
  final String answer;
  final String explanation;
  final String age;

  FillGameQuestion({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
    required this.age,
  });

  factory FillGameQuestion.fromJson(Map<String, dynamic> json) {
    return FillGameQuestion(
      id: json['id'] as String,
      type: json['type'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answer: json['answer'] as String,
      explanation: json['explanation'] as String,
      age: json['age'] as String,
    );
  }
}

class SentenceGameQuestion {
  final String id;
  final String type;
  final String question;
  final List<String> options;
  final String answer;

  SentenceGameQuestion({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.answer,
  });

  factory SentenceGameQuestion.fromJson(Map<String, dynamic> json) {
    return SentenceGameQuestion(
      id: json['id'] as String,
      type: json['type'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answer: json['answer'] as String,
    );
  }
}

class AudioGameQuestion {
  final String audioFile;
  final String answer;
  final List<String> options;

  AudioGameQuestion({
    required this.audioFile,
    required this.answer,
    required this.options,
  });

  static List<AudioGameQuestion> getFixedQuestions() {
    final questions = [
      AudioGameQuestion(
        audioFile: 'bell ringing.mp3',
        answer: 'Bell',
        options: ['Bell', 'Alarm', 'Phone', 'Clock'],
      ),
      AudioGameQuestion(
        audioFile: 'cat meo.mp3',
        answer: 'Cat',
        options: ['Cat', 'Dog', 'Bird', 'Lion'],
      ),
      AudioGameQuestion(
        audioFile: 'dog barking.mp3',
        answer: 'Dog',
        options: ['Dog', 'Wolf', 'Fox', 'Bear'],
      ),
      AudioGameQuestion(
        audioFile: 'gun shots.mp3',
        answer: 'Gun',
        options: ['Gun', 'Fireworks', 'Explosion', 'Thunder'],
      ),
      AudioGameQuestion(
        audioFile: 'train horn.mp3',
        answer: 'Train',
        options: ['Train', 'Bus', 'Car', 'Truck'],
      ),
    ];

    // Shuffle the questions for randomization
    questions.shuffle();
    return questions;
  }
}

class GameService {
  static Future<List<ImageMatchQuestion>> loadImageMatchQuestions(
    int age,
  ) async {
    try {
      print('GameService: Loading questions for age $age');

      // Load the JSON file
      final String jsonString = await rootBundle.loadString(
        'assets/kids_game_data.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      print('GameService: JSON data loaded successfully');

      // Determine age group
      String ageGroup;
      if (age >= 2 && age <= 4) {
        ageGroup = 'age2to4';
      } else if (age >= 5 && age <= 7) {
        ageGroup = 'age5to7';
      } else {
        ageGroup = 'age8-20'; // Fixed: Changed to match JSON key
      }
      print('GameService: Selected age group: $ageGroup');

      // Get questions for the age group
      final List<dynamic> questionsData = jsonData[ageGroup] as List<dynamic>;
      print(
        'GameService: Found ${questionsData.length} questions for age group $ageGroup',
      );

      // Convert to List of ImageMatchQuestion objects
      List<ImageMatchQuestion> allQuestions =
          questionsData
              .map(
                (q) => ImageMatchQuestion.fromJson(q as Map<String, dynamic>),
              )
              .toList();

      // Randomly select 5 questions
      if (allQuestions.length > 5) {
        allQuestions.shuffle(Random());
        allQuestions = allQuestions.take(5).toList();
      }

      print('GameService: Returning ${allQuestions.length} questions');
      return allQuestions;
    } catch (e) {
      print('GameService: Error loading questions: $e');
      print('GameService: Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  static Future<List<FillGameQuestion>> loadFillGameQuestions(int age) async {
    try {
      // Load the JSON file
      final String jsonString = await rootBundle.loadString(
        'assets/fill_questions_by_age.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString) as List<dynamic>;

      // Convert all questions to FillGameQuestion objects
      final allQuestions =
          jsonData
              .map((q) => FillGameQuestion.fromJson(q as Map<String, dynamic>))
              .toList();

      // Filter questions based on age
      String ageGroup;
      if (age >= 2 && age <= 4) {
        ageGroup = '2-4';
      } else if (age >= 5 && age <= 7) {
        ageGroup = '5-7';
      } else {
        ageGroup = '8-20';
      }

      // Filter questions for the appropriate age group
      final ageAppropriateQuestions =
          allQuestions.where((q) => q.age == ageGroup).toList();

      // Randomly select 5 questions
      if (ageAppropriateQuestions.length > 5) {
        ageAppropriateQuestions.shuffle(Random());
        return ageAppropriateQuestions.take(5).toList();
      }

      return ageAppropriateQuestions;
    } catch (e) {
      print('Error loading fill game questions: $e');
      return [];
    }
  }

  static Future<List<SentenceGameQuestion>> loadSentenceGameQuestions(
    int age,
  ) async {
    try {
      print('Loading sentence game questions for age: $age');

      // Load the JSON file
      final String jsonString = await rootBundle.loadString(
        'assets/sentence_game_questions_by_age.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Determine age group
      String ageGroup;
      if (age >= 2 && age <= 4) {
        ageGroup = '2-4';
      } else if (age >= 5 && age <= 7) {
        ageGroup = '5-7';
      } else if (age >= 8 && age <= 10) {
        ageGroup = '8-10';
      } else if (age >= 11 && age <= 15) {
        ageGroup = '11-15';
      } else {
        ageGroup = '16-20'; // Default to highest age group for ages > 15
      }

      print('Selected age group: $ageGroup');

      // Get questions for the age group
      final List<dynamic>? questionsData = jsonData[ageGroup] as List<dynamic>?;

      if (questionsData == null || questionsData.isEmpty) {
        print('No questions found for age group: $ageGroup');
        return [];
      }

      print('Found ${questionsData.length} questions for age group $ageGroup');

      // Convert to List of SentenceGameQuestion objects
      List<SentenceGameQuestion> allQuestions =
          questionsData
              .map(
                (q) => SentenceGameQuestion.fromJson(q as Map<String, dynamic>),
              )
              .toList();

      // Randomly select 5 questions
      if (allQuestions.length > 5) {
        allQuestions.shuffle(Random());
        allQuestions = allQuestions.take(5).toList();
      }

      print('Returning ${allQuestions.length} questions');
      return allQuestions;
    } catch (e, stackTrace) {
      print('Error loading sentence game questions: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<List<AudioGameQuestion>> loadAudioGameQuestions(int age) async {
    // Return the fixed set of questions regardless of age
    return AudioGameQuestion.getFixedQuestions();
  }
}
