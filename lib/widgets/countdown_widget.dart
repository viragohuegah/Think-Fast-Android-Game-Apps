import 'dart:async';
import 'package:flutter/material.dart';
import '../core/audio/audio_service.dart';
import '../core/haptic/haptic_service.dart';

class CountdownWidget extends StatefulWidget {
  const CountdownWidget({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget>
    with SingleTickerProviderStateMixin {
  static const _steps = ['3', '2', '1', 'Go!'];

  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );
    _scale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );

    _playStep();
    _ctrl.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_index >= _steps.length - 1) {
        _timer?.cancel();
        Future<void>.delayed(
            const Duration(milliseconds: 500), widget.onComplete);
        return;
      }
      setState(() => _index++);
      _playStep();
      _ctrl
        ..reset()
        ..forward();
    });
  }

  void _playStep() {
    final isGo = _index == _steps.length - 1;

    if (isGo) {
      AudioService.instance.playRoundStart();
      HapticService.medium();
    } else {
      AudioService.instance.playTick();
      HapticService.light();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isStart = _index == _steps.length - 1;

    return Center(
      child: ScaleTransition(
        scale: _scale,
        child: FadeTransition(
          opacity: _fade,
          child: Text(
            _steps[_index],
            style: TextStyle(
              fontSize: isStart ? 52 : 124,
              fontWeight: FontWeight.w900,
              color:
                  isStart ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
              letterSpacing: isStart ? 4 : 0,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
