import 'dart:math';
import '../models/question_result.dart';
import '../models/round_result.dart';

/// Single addition question (0–9 + 0–9).
final class Question {
  final int a;
  final int b;

  const Question({required this.a, required this.b});

  int get result => a + b;
  bool get isEven => result % 2 == 0;

  /// Canonical correct answer: 0 = Even, 1 = Odd.
  int get correctAnswer => isEven ? 0 : 1;

  @override
  String toString() => '$a + $b';
}

/// Pure-Dart game engine. No Flutter dependencies.
/// Owns all game state; UI observes it via callbacks.
final class GameEngine {
  GameEngine({required this.totalRounds});

  final int totalRounds;

  // ── State ──────────────────────────────────────────────────────────────────
  final List<RoundResult> roundResults = [];
  final Random _random = Random();

  final List<QuestionResult> _currentRoundResults = [];
  DateTime? _questionStartTime;
  late Question _currentQuestion;
  int _currentRound = 0;

  // ── Accessors ──────────────────────────────────────────────────────────────
  int get currentRoundNumber => _currentRound;
  bool get isLastRound => _currentRound >= totalRounds;
  Question get currentQuestion => _currentQuestion;

  // ── Round lifecycle ────────────────────────────────────────────────────────
  void startRound() {
    _currentRound++;
    _currentRoundResults.clear();
    _generateNextQuestion();
  }

  void _generateNextQuestion() {
    _currentQuestion = Question(
      a: _random.nextInt(10),
      b: _random.nextInt(10),
    );
    _questionStartTime = DateTime.now();
  }

  /// Call when user taps an answer button.
  /// Returns whether the answer was correct.
  bool submitAnswer(int answer) {
    final responseTime = _questionStartTime != null
        ? DateTime.now()
                .difference(_questionStartTime!)
                .inMilliseconds /
            1000.0
        : 0.0;

    final isCorrect = answer == _currentQuestion.correctAnswer;

    _currentRoundResults.add(QuestionResult(
      isCorrect: isCorrect,
      responseTime: double.parse(responseTime.toStringAsFixed(2)),
    ));

    _generateNextQuestion();
    return isCorrect;
  }

  /// Call when the 60-second timer expires. Returns the completed RoundResult.
  RoundResult finalizeRound() {
    final total = _currentRoundResults.length;
    final correct = _currentRoundResults.where((r) => r.isCorrect).length;
    final wrong = total - correct;
    final avgRT = total == 0
        ? 0.0
        : _currentRoundResults
                .map((r) => r.responseTime)
                .reduce((a, b) => a + b) /
            total;

    final result = RoundResult(
      roundNumber: _currentRound,
      totalQuestions: total,
      correctAnswers: correct,
      wrongAnswers: wrong,
      averageResponseTime: double.parse(avgRT.toStringAsFixed(2)),
    );

    roundResults.add(result);
    return result;
  }

  // ── Aggregate stats ────────────────────────────────────────────────────────
  int get totalQuestions =>
      roundResults.fold(0, (sum, r) => sum + r.totalQuestions);

  int get totalCorrect =>
      roundResults.fold(0, (sum, r) => sum + r.correctAnswers);

  int get totalWrong =>
      roundResults.fold(0, (sum, r) => sum + r.wrongAnswers);

  double get overallAccuracy => totalQuestions == 0
      ? 0.0
      : (totalCorrect / totalQuestions) * 100;

  double get overallAverageResponseTime {
    if (roundResults.isEmpty) return 0.0;
    final avg = roundResults
            .map((r) => r.averageResponseTime)
            .reduce((a, b) => a + b) /
        roundResults.length;
    return double.parse(avg.toStringAsFixed(2));
  }

  double get overallCPS => totalCorrect / (totalRounds * 60.0);
}
