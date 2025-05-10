import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_selection_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  double _age = 10; // Default age

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getAgeCategory(double age) {
    if (age < 8) return '🌱 Young Learner';
    if (age < 13) return '🌟 Junior Explorer';
    if (age < 18) return '🚀 Teen Adventurer';
    return '🎓 Knowledge Seeker';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(
        context,
      ).pushReplacementNamed('/game-selection', arguments: _age.round());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C3E50), // Dark blue-gray
              Color(0xFF1A1A2E), // Deep navy
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20.0 : 32.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game Logo
                  Hero(
                    tag: 'game_logo',
                    child: Container(
                      width: isSmallScreen ? 120 : 140,
                      height: isSmallScreen ? 120 : 140,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFFFA500),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFA500).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/sheshya.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    'SHESHYA',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 32 : 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFA500),
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Begin Your Learning Adventure',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Profile Form
                  Container(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter Player Name',
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.white10,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: Color(0xFFFFA500),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name required to start';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          // New Age Selector
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.emoji_events_outlined,
                                      color: Color(0xFFFFA500),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getAgeCategory(_age),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Minus button
                                    IconButton(
                                      onPressed: () {
                                        if (_age > 2) {
                                          setState(() {
                                            _age--;
                                          });
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Color(0xFFFFA500),
                                        size: 28,
                                      ),
                                    ),
                                    // Slider
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          activeTrackColor: const Color(
                                            0xFFFFA500,
                                          ),
                                          inactiveTrackColor: Colors.white24,
                                          thumbColor: const Color(0xFFFFA500),
                                          overlayColor: const Color(
                                            0xFFFFA500,
                                          ).withOpacity(0.2),
                                          valueIndicatorColor: const Color(
                                            0xFFFFA500,
                                          ),
                                          valueIndicatorTextStyle:
                                              const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        child: Slider(
                                          value: _age,
                                          min: 2,
                                          max: 60,
                                          divisions: 58,
                                          label: _age.round().toString(),
                                          onChanged: (value) {
                                            setState(() {
                                              _age = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    // Plus button
                                    IconButton(
                                      onPressed: () {
                                        if (_age < 60) {
                                          setState(() {
                                            _age++;
                                          });
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Color(0xFFFFA500),
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Age: ${_age.round()} years',
                                  style: const TextStyle(
                                    color: Color(0xFFFFA500),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFA500),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'START GAME',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
