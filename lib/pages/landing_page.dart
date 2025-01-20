import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_page.dart';
import '../utils/language_controller.dart';
import '../pages/history_page.dart';
import 'package:clay_containers/clay_containers.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int selectedDuration = 60;
  int selectedDifficulty = 1;

  final Map<int, Map<String, String>> durationOptions = {
    60: {'en': '1 min', 'zh': '1 分钟'},
    90: {'en': '2 min', 'zh': '2 分钟'},
    -1: {'en': 'Endless', 'zh': '无限模式'},
  };

  final Map<int, Map<String, String>> difficultyOptions = {
    1: {'en': 'Level 1', 'zh': '第一级'},
    2: {'en': 'Level 2', 'zh': '第二级'},
    3: {'en': 'Level 3', 'zh': '第三级'},
    4: {'en': 'Level 4', 'zh': '第四级'},
  };

  @override
  Widget build(BuildContext context) {
    final languageController = Provider.of<LanguageController>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade400,
              Colors.red.shade400,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon

                    Text(
                      languageController.getText(
                        'Brain Spectrum',
                        '脑力光谱',
                      ),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      languageController.getText(
                        'Train your brain with colors!',
                        '用颜色训练你的大脑！',
                      ),
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey[700],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Duration Dropdown
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedDuration,
                          isExpanded: true,
                          icon: const Icon(Icons.timer),
                          iconSize: 32,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.black87,
                          ),
                          items: durationOptions.entries.map((entry) {
                            return DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(
                                languageController.getText(
                                  entry.value['en']!,
                                  entry.value['zh']!,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDuration = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Difficulty Dropdown
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedDifficulty,
                          isExpanded: true,
                          icon: const Icon(Icons.grade),
                          iconSize: 32,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.black87,
                          ),
                          items: difficultyOptions.entries.map((entry) {
                            return DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(
                                languageController.getText(
                                  entry.value['en']!,
                                  entry.value['zh']!,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDifficulty = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Start Game Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChangeNotifierProvider.value(
                                value: Provider.of<LanguageController>(context,
                                    listen: false),
                                child: GamePage(
                                  gameDuration: selectedDuration,
                                  difficulty: selectedDifficulty,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          languageController.getText(
                            'Start Game',
                            '开始游戏',
                          ),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // History Button
                    ClayContainer(
                      depth: 20,
                      spread: 4,
                      borderRadius: 16,
                      color: Colors.white,
                      emboss: false,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProvider.value(
                                  value: Provider.of<LanguageController>(
                                      context,
                                      listen: false),
                                  child: const HistoryPage(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.3),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              languageController.getText(
                                'Game History',
                                '游戏记录',
                              ),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Language Toggle Button
            Positioned(
              top: 48,
              right: 24,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.language, size: 20),
                  label: Text(
                    languageController.getText('EN', '中文'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    languageController.toggleLanguage();
                  },
                ),
              ),
            ),

            // Version Banner
            Positioned(
              bottom: 8,
              right: 8,
              child: Text(
                'v1.0.1',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
