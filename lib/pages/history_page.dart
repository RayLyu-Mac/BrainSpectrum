import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/database_helper.dart';
import '../utils/language_controller.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  String _formatDuration(int duration) {
    if (duration == -1) return 'Endless';
    return '${duration ~/ 60} min';
  }

  String _formatDifficulty(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Basic';
      case 2:
        return 'Border';
      case 3:
        return 'Mixed';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageController = Provider.of<LanguageController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageController.getText('Game History', '游戏记录'),
          style: const TextStyle(fontSize: 24),
        ),
      ),
      body: FutureBuilder<List<GameScore>>(
        future: DatabaseHelper.instance.getAllScores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                languageController.getText(
                  'No game history yet',
                  '暂无游戏记录',
                ),
                style: const TextStyle(fontSize: 20),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final score = snapshot.data![index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        languageController.getText(
                          'Score: ${score.score}',
                          '得分：${score.score}',
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        score.timestamp.toString().substring(0, 16),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          languageController.getText(
                            _formatDifficulty(score.difficulty),
                            score.difficulty == 1
                                ? '基础'
                                : score.difficulty == 2
                                    ? '边框'
                                    : '混合',
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          languageController.getText(
                            _formatDuration(score.duration),
                            score.duration == -1
                                ? '无限模式'
                                : '${score.duration ~/ 60} 分钟',
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
