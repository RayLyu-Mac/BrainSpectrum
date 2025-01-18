import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'landing_page.dart';
import 'package:provider/provider.dart';
import '../utils/language_controller.dart';
import '../utils/database_helper.dart';

class GamePage extends StatefulWidget {
  final int gameDuration;
  final int difficulty;
  const GamePage({
    super.key,
    required this.gameDuration,
    required this.difficulty,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  int score = 0;
  List<Color> allColors = [
    Color.fromARGB(255, 253, 29, 29),
    Color.fromARGB(227, 49, 186, 240),
    Colors.green,
    Color.fromARGB(255, 226, 196, 0),
    Color.fromARGB(255, 255, 94, 0),
    Colors.black,
    Color.fromARGB(255, 29, 47, 150),
    const Color.fromARGB(255, 182, 48, 206),
  ];

  Map<String, String> colorTranslations = {
    'Red': '红色',
    'Blue': '蓝色',
    'Green': '绿色',
    'Yellow': '黄色',
    'Orange': '橙色',
    'Black': '黑色',
    'Indigo': '青紫色',
    'Purple': '紫色',
  };

  List<String> allColorNames = [
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Orange',
    'Black',
    'Indigo',
    'Purple'
  ];

  late String correctAnswer;
  late Color questionColor;
  late List<String> currentOptions;
  late Timer _timer;
  int _secondsRemaining = 0;

  late final AnimationController _scoreController;

  int strikes = 0;
  static const int maxStrikes = 3;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _secondsRemaining = widget.gameDuration;
    _generateNewQuestion();
    _startTimer();
  }

  void _generateNewQuestion() {
    final random = Random();
    int correctIndex = random.nextInt(allColorNames.length);
    correctAnswer = allColorNames[correctIndex];

    do {
      questionColor = allColors[random.nextInt(allColors.length)];
    } while (allColorNames[allColors.indexOf(questionColor)] == correctAnswer);

    Set<String> optionsSet = {correctAnswer};
    while (optionsSet.length < (widget.difficulty >= 3 ? 6 : 4)) {
      optionsSet.add(allColorNames[random.nextInt(allColorNames.length)]);
    }
    currentOptions = optionsSet.toList()..shuffle();
  }

  void _startTimer() {
    if (widget.gameDuration > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer.cancel();
            _showGameOverDialog();
          }
        });
      });
    }
  }

  void _showGameOverDialog() {
    // Save score to database
    final gameScore = GameScore(
      score: score,
      duration: widget.gameDuration,
      difficulty: widget.difficulty,
      timestamp: DateTime.now(),
    );
    DatabaseHelper.instance.insertScore(gameScore);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final languageController = Provider.of<LanguageController>(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                score > widget.gameDuration / 2
                    ? Icons.emoji_events
                    : Icons.mood,
                size: 50,
                color: Colors.amber,
              ),
              const SizedBox(height: 10),
              Text(languageController.getText('Game Over!', '游戏结束！')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toString(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                languageController.getText('points', '分'),
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: Provider.of<LanguageController>(context,
                          listen: false),
                      child: GamePage(
                          gameDuration: widget.gameDuration,
                          difficulty: widget.difficulty),
                    ),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(languageController.getText('Start Another', '再来一次')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LandingPage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(languageController.getText('Back to Menu', '返回菜单')),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _scoreController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  ButtonStyle _getButtonStyle(String colorName, int index) {
    Color buttonColor = allColors[allColorNames.indexOf(colorName)];

    switch (widget.difficulty) {
      case 1: // Solid color only
        return ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 18,
          ),
        );

      case 2: // Border with matching text
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: buttonColor, width: 5),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 18,
          ),
        );

      case 3: // Border with different text color
        String randomColorName =
            allColorNames[Random().nextInt(allColorNames.length)];
        Color textColor = allColors[allColorNames.indexOf(randomColorName)];
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: buttonColor, width: 5),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 18,
          ),
          foregroundColor: textColor,
        );

      case 4: // Different fill and text
        String randomColorName;
        Color fillColor;
        do {
          randomColorName =
              allColorNames[Random().nextInt(allColorNames.length)];
          fillColor = allColors[allColorNames.indexOf(randomColorName)];
        } while (randomColorName == colorName);

        return ElevatedButton.styleFrom(
          backgroundColor: fillColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: fillColor, width: 5),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 18,
          ),
          foregroundColor: Colors.white,
        );

      default:
        return ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 18,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageController = Provider.of<LanguageController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedBuilder(
              animation: _scoreController,
              builder: (context, child) {
                return Text(
                  'Score: $score',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _scoreController.isAnimating
                        ? (score % 2 == 0 ? Colors.red : Colors.green)
                        : null,
                  ),
                );
              },
            ),
            widget.gameDuration > 0
                ? Text(_formatTime(_secondsRemaining))
                : Text('❤️' * (maxStrikes - strikes)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _timer.cancel();
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _secondsRemaining / widget.gameDuration,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _secondsRemaining < 10 ? Colors.red : Colors.green,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 30,
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                          text: languageController.getText('Select ', '选择')),
                      TextSpan(
                        text: languageController.getText(
                          correctAnswer.toUpperCase(),
                          colorTranslations[correctAnswer]!,
                        ),
                        style: TextStyle(
                          color: questionColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: widget.difficulty >= 3 ? 1.1 : 0.65,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: List.generate(
                widget.difficulty >= 3 ? 6 : 4,
                (index) => ElevatedButton(
                  style: _getButtonStyle(currentOptions[index], index),
                  onPressed: () {
                    if (currentOptions[index] == correctAnswer) {
                      setState(() {
                        score++;
                        _scoreController.forward(from: 0);
                        _generateNewQuestion();
                      });
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              languageController.getText(
                                'Correct!',
                                '正确！',
                              ),
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(milliseconds: 300),
                            behavior: SnackBarBehavior.floating,
                            dismissDirection: DismissDirection.horizontal,
                          ),
                        );
                    } else {
                      setState(() {
                        score = (score - 2).clamp(0, double.infinity).toInt();
                        strikes++;
                        if (strikes >= maxStrikes) {
                          _timer.cancel();
                          _showGameOverDialog();
                        }
                      });
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              languageController.getText(
                                'Wrong answer! -2 points (Strike ${strikes}/${maxStrikes})',
                                '答错了！扣2分 (失误 ${strikes}/${maxStrikes})',
                              ),
                            ),
                            backgroundColor: Colors.red,
                            duration: const Duration(milliseconds: 300),
                            behavior: SnackBarBehavior.floating,
                            dismissDirection: DismissDirection.horizontal,
                          ),
                        );
                    }
                  },
                  child: Text(
                    widget.difficulty == 1
                        ? ''
                        : languageController.getText(
                            currentOptions[index],
                            colorTranslations[currentOptions[index]]!,
                          ),
                    style: TextStyle(
                      color: widget.difficulty == 1
                          ? (allColors[allColorNames
                                      .indexOf(currentOptions[index])] ==
                                  const Color.fromARGB(255, 255, 234, 0)
                              ? Colors.black
                              : Colors.white)
                          : widget.difficulty == 2
                              ? allColors[
                                  allColorNames.indexOf(currentOptions[index])]
                              : widget.difficulty == 4
                                  ? Colors.white
                                  : null,
                      fontWeight: FontWeight.w900,
                      fontSize: 34,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
