import 'dart:async';
import 'package:flutter/material.dart';
import '../core/audio/audio_service.dart';
import '../core/haptic/haptic_service.dart';
import '../core/theme/app_theme.dart';
import '../services/game_engine.dart';
import '../widgets/answer_button.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/question_card.dart';
import 'result_screen.dart';

enum _Phase { countdown, playing, transitioning }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  _Phase _phase = _Phase.countdown;
  int _timeLeft = 60;
  Timer? _roundTimer;
  Timer? _feedbackTimer;

  int _questionKey = 0;
  bool? _lastCorrect; // null = no flash

  GameEngine get _engine => widget.engine;

  @override
  void initState() {
    super.initState();
    _engine.startRound();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  // ── Countdown ──────────────────────────────────────────────────────────────
  void _onCountdownComplete() {
    if (!mounted) return;
    setState(() => _phase = _Phase.playing);
    _startTimer();
  }

  // ── Timer ──────────────────────────────────────────────────────────────────
  void _startTimer() {
    _timeLeft = 60;
    _roundTimer?.cancel();
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final next = _timeLeft - 1;
      setState(() => _timeLeft = next);

      if (next <= 5 && next > 0) HapticService.light();
      if (next <= 0) {
        timer.cancel();
        _endRound();
      }
    });
  }

  void _endRound() {
    AudioService.instance.playRoundEnd();
    HapticService.heavy();
    _engine.finalizeRound();

    if (_engine.isLastRound) {
      _navigateToResult();
      return;
    }

    setState(() => _phase = _Phase.transitioning);

    Future<void>.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _engine.startRound();
      setState(() {
        _phase = _Phase.countdown;
        _timeLeft = 60;
        _questionKey++;
        _lastCorrect = null;
      });
    });
  }

  void _navigateToResult() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(engine: _engine),
      ),
    );
  }

  // ── Answer ─────────────────────────────────────────────────────────────────
  void _onAnswer(int answer) {
    if (_phase != _Phase.playing) return;

    final isCorrect = _engine.submitAnswer(answer);

    // Audio + Haptic
    if (isCorrect) {
      AudioService.instance.playCorrect();
      HapticService.success();
    } else {
      AudioService.instance.playWrong();
      HapticService.error();
    }

    // Flash feedback
    _feedbackTimer?.cancel();
    setState(() {
      _lastCorrect = isCorrect;
      _questionKey++;
    });
    _feedbackTimer = Timer(const Duration(milliseconds: 280), () {
      if (mounted) setState(() => _lastCorrect = null);
    });
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  Color get _bgColor {
    if (_lastCorrect == true) return AppColors.successLight;
    if (_lastCorrect == false) return AppColors.dangerLight;
    return AppColors.surface;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      color: _bgColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: switch (_phase) {
            _Phase.countdown => _Countdown(
                engine: _engine,
                onComplete: _onCountdownComplete,
              ),
            _Phase.transitioning => const Center(
                child: Text(
                  'Take a breath...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            _Phase.playing => _GamePlay(
                engine: _engine,
                timeLeft: _timeLeft,
                questionKey: _questionKey,
                lastCorrect: _lastCorrect,
                onAnswer: _onAnswer,
              ),
          },
        ),
      ),
    );
  }
}

// ─── Countdown sub-widget ──────────────────────────────────────────────────

class _Countdown extends StatelessWidget {
  const _Countdown({required this.engine, required this.onComplete});

  final GameEngine engine;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RoundBadge(engine: engine, timeLeft: 60),
        Expanded(child: CountdownWidget(onComplete: onComplete)),
      ],
    );
  }
}

// ─── Gameplay sub-widget ───────────────────────────────────────────────────

class _GamePlay extends StatelessWidget {
  const _GamePlay({
    required this.engine,
    required this.timeLeft,
    required this.questionKey,
    required this.lastCorrect,
    required this.onAnswer,
  });

  final GameEngine engine;
  final int timeLeft;
  final int questionKey;
  final bool? lastCorrect;
  final void Function(int) onAnswer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _RoundBadge(engine: engine, timeLeft: timeLeft),
          const SizedBox(height: 12),
          _TimerBar(timeLeft: timeLeft),
          const SizedBox(height: 28),

          // Question
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey<int>(questionKey),
              child: QuestionCard(question: engine.currentQuestion),
            ),
          ),

          const SizedBox(height: 14),
          _FeedbackLabel(lastCorrect: lastCorrect),
          const Spacer(),

          // Answer buttons
          Row(
            children: [
              Expanded(
                child: AnswerButton(value: 0, onTap: () => onAnswer(0)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnswerButton(value: 1, onTap: () => onAnswer(1)),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Reusable sub-widgets ──────────────────────────────────────────────────

class _RoundBadge extends StatelessWidget {
  const _RoundBadge({required this.engine, required this.timeLeft});

  final GameEngine engine;
  final int timeLeft;

  @override
  Widget build(BuildContext context) {
    final isLow = timeLeft <= 10;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Round ${engine.currentRoundNumber} / ${engine.totalRounds}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isLow ? AppColors.dangerLight : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 15,
                  color: isLow ? AppColors.danger : AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  '${timeLeft}s',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isLow ? AppColors.danger : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerBar extends StatelessWidget {
  const _TimerBar({required this.timeLeft});

  final int timeLeft;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: timeLeft / 60, end: timeLeft / 60),
        duration: const Duration(milliseconds: 900),
        builder: (_, value, __) => LinearProgressIndicator(
          value: timeLeft / 60,
          minHeight: 6,
          backgroundColor: const Color(0xFFE2E8F0),
          valueColor: AlwaysStoppedAnimation<Color>(
            timeLeft <= 10 ? AppColors.danger : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _FeedbackLabel extends StatelessWidget {
  const _FeedbackLabel({required this.lastCorrect});

  final bool? lastCorrect;

  @override
  Widget build(BuildContext context) {
    if (lastCorrect == null) return const SizedBox(height: 24);
    return Text(
      lastCorrect! ? '✓  Correct!' : '✗  Incorrect!',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: lastCorrect! ? AppColors.success : AppColors.danger,
      ),
    );
  }
}
