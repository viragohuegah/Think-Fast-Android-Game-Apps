/// Immutable summary of a completed round.
final class RoundResult {
  final int roundNumber;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double averageResponseTime; // seconds

  const RoundResult({
    required this.roundNumber,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.averageResponseTime,
  });

  /// Accuracy percentage 0–100.
  double get accuracy =>
      totalQuestions == 0 ? 0.0 : (correctAnswers / totalQuestions) * 100;

  /// Correct answers per second (over the full 60-second round).
  double get correctPerSecond => correctAnswers / 60.0;
}
