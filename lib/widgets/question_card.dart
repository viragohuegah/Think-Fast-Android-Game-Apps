import 'package:flutter/material.dart';
import '../services/game_engine.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        '${question.a}  +  ${question.b}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 76,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: Color(0xFF1E293B),
          height: 1,
        ),
      ),
    );
  }
}
