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
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  bool _isStorageAvailable = true;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database?> get database async {
    if (!_isStorageAvailable) return null;

    if (_database != null) return _database;

    try {
      _database = await _initDB('game_scores.db');
      return _database;
    } catch (e) {
      print('Storage initialization error: $e');
      _isStorageAvailable = false;
      return null;
    }
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

  Future<bool> insertScore(GameScore score) async {
    if (!_isStorageAvailable) return false;

    try {
      final db = await database;
      if (db == null) return false;

      await db.insert('scores', score.toMap());
      return true;
    } catch (e) {
      print('Storage operation error: $e');
      _isStorageAvailable = false;
      return false;
    }
  }

  Future<int> getTopScore(int difficulty, int duration) async {
    if (!_isStorageAvailable) return 0;

    try {
      final db = await database;
      if (db == null) return 0;

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
    } catch (e) {
      print('Storage query error: $e');
      _isStorageAvailable = false;
      return 0;
    }
  }

  Future<List<GameScore>> getAllScores() async {
    if (!_isStorageAvailable) return [];

    try {
      final db = await database;
      if (db == null) return [];

      final List<Map<String, dynamic>> maps = await db.query(
        'scores',
        orderBy: 'timestamp DESC',
      );

      return List.generate(maps.length, (i) => GameScore.fromMap(maps[i]));
    } catch (e) {
      print('Storage query error: $e');
      _isStorageAvailable = false;
      return [];
    }
  }

  bool get isStorageAvailable => _isStorageAvailable;
}
