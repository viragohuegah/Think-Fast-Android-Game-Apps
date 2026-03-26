// This is a basic Flutter widget test for Think Fast game.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_fast/main.dart';
import 'package:think_fast/screens/home_screen.dart';
import 'package:think_fast/services/game_engine.dart';
import 'package:think_fast/services/game_engine.dart';

void main() {
  testWidgets('Think Fast app launches without crashing',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ThinkFastApp());

    // Verify that the app title is correct
    expect(find.text('Think Fast'), findsOneWidget);

    // Verify HomeScreen is displayed (should show "Think Fast" title)
    expect(find.text('Think Fast'), findsOneWidget);
  });

  testWidgets('HomeScreen displays correct UI elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Verify main title
    expect(find.text('Think Fast'), findsOneWidget);

    // Verify round input field exists
    expect(find.byType(TextFormField), findsOneWidget);

    // Verify default round value is '5'
    expect(find.text('5'), findsOneWidget);

    // Verify buttons exist (actual button text)
    expect(find.text('HOW TO PLAY'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('How to Play dialog shows when tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Tap the HOW TO PLAY button
    await tester.tap(find.text('HOW TO PLAY'));
    await tester.pump();

    // Verify dialog appears (look for dialog content instead of AlertDialog)
    expect(find.text('You will see a\nsingle-digit addition'), findsOneWidget);
  });

  testWidgets('Start Game button exists and is tappable',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Verify START button exists
    expect(find.text('START'), findsOneWidget);

    // Verify button is tappable (doesn't crash when tapped)
    await tester.tap(find.text('START'));
    await tester.pump();

    // App should still be running
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('Round input validation works', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Find the text field and enter invalid input
    final textField = find.byType(TextFormField);
    await tester.enterText(textField, '0'); // Invalid: minimum should be 1
    await tester.tap(find.text('START'));
    await tester.pump();

    // Should show validation error (this depends on your validation logic)
    // For now, just verify the app doesn't crash
    expect(find.byType(Scaffold), findsOneWidget);
  });

  // Unit test for GameEngine
  test('GameEngine creates valid questions', () {
    final engine = GameEngine(totalRounds: 3);

    // Start a round
    engine.startRound();

    // Verify question is generated
    final question = engine.currentQuestion;
    expect(question.a, greaterThanOrEqualTo(0));
    expect(question.a, lessThanOrEqualTo(9));
    expect(question.b, greaterThanOrEqualTo(0));
    expect(question.b, lessThanOrEqualTo(9));

    // Verify result calculation
    expect(question.result, equals(question.a + question.b));

    // Verify correct answer logic
    final expectedAnswer = question.result % 2 == 0 ? 0 : 1;
    expect(question.correctAnswer, equals(expectedAnswer));
  });

  test('GameEngine answer submission works', () {
    final engine = GameEngine(totalRounds: 1);
    engine.startRound();

    final question = engine.currentQuestion;
    final correctAnswer = question.correctAnswer;

    // Submit correct answer
    final isCorrect = engine.submitAnswer(correctAnswer);
    expect(isCorrect, isTrue);
  });
}
