import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GameScore {
  final int? id;
  final int score;
  final int difficulty;
  final int duration;
  final DateTime timestamp;

  GameScore({
    this.id,
    required this.score,
    required this.difficulty,
    required this.duration,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'score': score,
      'difficulty': difficulty,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static GameScore fromMap(Map<String, dynamic> map) {
    return GameScore(
      id: map['id'],
      score: map['score'],
      difficulty: map['difficulty'],
      duration: map['duration'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('game_scores.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER NOT NULL,
        difficulty INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertScore(GameScore score) async {
    final db = await database;
    await db.insert('scores', score.toMap());
  }

  Future<int> getTopScore(int difficulty, int duration) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scores',
      where: 'difficulty = ? AND duration = ?',
      whereArgs: [difficulty, duration],
      orderBy: 'score DESC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return 0;
    }

    return maps.first['score'];
  }

  Future<List<GameScore>> getAllScores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scores',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) => GameScore.fromMap(maps[i]));
  }
}
