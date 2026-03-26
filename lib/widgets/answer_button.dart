import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.value,
    required this.onTap,
    this.enabled = true,
  });

  final int value; // 0 = Even, 1 = Odd
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isEven = value == 0;
    final color = isEven ? AppColors.primary : AppColors.secondary;
    final bgLight = isEven ? AppColors.primaryLight : AppColors.secondaryLight;
    final label = isEven ? 'EVEN' : 'ODD';

    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Ink(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
