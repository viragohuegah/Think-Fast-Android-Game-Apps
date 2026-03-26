/// Immutable result for a single answered question.
final class QuestionResult {
  final bool isCorrect;
  final double responseTime; // in seconds, 2-decimal precision

  const QuestionResult({
    required this.isCorrect,
    required this.responseTime,
  });
}
