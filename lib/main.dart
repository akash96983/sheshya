import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'game_selection_page.dart';
import 'fill_game_page.dart';
import 'image_match_game_page.dart';
import 'audio_game_page.dart';
import 'sentence_game_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sheshya Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Poppins',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => const ProfilePage());
        } else if (settings.name == '/game-selection') {
          final age = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (context) => GameSelectionPage(age: age ?? 0),
          );
        } else if (settings.name == '/image-match') {
          final age = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (context) => ImageMatchGamePage(age: age ?? 0),
          );
        } else if (settings.name == '/fill-game') {
          final age = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (context) => FillGamePage(age: age ?? 0),
          );
        } else if (settings.name == '/audio-game') {
          final age = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (context) => AudioGamePage(age: age ?? 0),
          );
        } else if (settings.name == '/sentence-game') {
          final age = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (context) => SentenceGamePage(age: age ?? 0),
          );
        }
        return null;
      },
    );
  }
}
