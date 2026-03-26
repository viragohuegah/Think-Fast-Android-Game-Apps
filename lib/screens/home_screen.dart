import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/haptic/haptic_service.dart';
import '../core/theme/app_theme.dart';
import '../services/game_engine.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _roundController = TextEditingController(text: '5');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _roundController.dispose();
    super.dispose();
  }

  void _showHowToPlay() {
    HapticService.light();
    showDialog<void>(
      context: context,
      builder: (_) => const _HowToPlayDialog(),
    );
  }

  Future<void> _startGame() async {
    if (!_formKey.currentState!.validate()) return;
    final rounds = int.parse(_roundController.text.trim());
    HapticService.medium();

    final engine = GameEngine(totalRounds: rounds);

    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => GameScreen(engine: engine)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Brand ──────────────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/icon_color.png',
                            width: 148,
                            height: 144,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Think Fast',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Odd or Even?\nSingle Digit Speed Math Challenge",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── Round input ────────────────────────────────────────
                  const Text(
                    'Number of Rounds',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _roundController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Example: 5',
                      hintStyle: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                    ),
                    validator: (value) {
                      final n = int.tryParse(value?.trim() ?? '');
                      if (n == null || n < 1) {
                        return 'Enter a number ≥ 1';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '  60 seconds / round',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Buttons ────────────────────────────────────────────
                  ElevatedButton(
                    onPressed: _startGame,
                    child: const Text('START'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _showHowToPlay,
                    icon: const Icon(Icons.help_outline_rounded, size: 18),
                    label: const Text(
                      'HOW TO PLAY',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── How To Play Dialog ──────────────────────────────

class _HowToPlayDialog extends StatefulWidget {
  const _HowToPlayDialog();

  @override
  State<_HowToPlayDialog> createState() => _HowToPlayDialogState();
}

class _HowToPlayDialogState extends State<_HowToPlayDialog> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _rules = [
    {
      'images': [
        'assets/images/tutorial/step1_1.png',
        'assets/images/tutorial/step1_2.png',
        'assets/images/tutorial/step1_3.png',
      ],
      'text': 'You will see a\nsingle-digit addition',
    },
    {
      'images': [
        'assets/images/tutorial/step2_1.gif',
      ],
      'text': 'If the sum is\nEVEN → PRESS 0',
    },
    {
      'images': [
        'assets/images/tutorial/step3_1.gif',
      ],
      'text': 'If the sum is\nODD → PRESS 1'
    },
    {
      'images': [
        'assets/images/tutorial/step4_1.gif',
      ],
      'text': ' 60 seconds per round\nAnswer as fast as you can!',
    },
    {
      'images': [
        'assets/images/tutorial/step5_1.gif',
      ],
      'text': 'After you press START,\na countdown will begin',
    },
    {
      'emoji': '➡️',
      'text': '⚠️\nTime’s up → next round begins.\nNO PAUSE BETWEEN ROUNDS!',
    },
    {
      'emoji': '🏁',
      'text':
          'After the last round, see full results (accuracy, average response time & charts).'
    },
    {
      'emoji': '📊',
      'text': 'Review your performance and try to improve in the next game!',
    },
  ];

  int _currentImageIndex = 0;
  Timer? _imageTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startImageSlideshow();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _imageTimer?.cancel();
    super.dispose();
  }

  void _startImageSlideshow() {
    _imageTimer?.cancel();
    _currentImageIndex = 0;
    if (_rules[_currentPage].containsKey('images')) {
      final images = _rules[_currentPage]['images'] as List<String>;
      if (images.length > 1) {
        _imageTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {
            _currentImageIndex = (_currentImageIndex + 1) % images.length;
          });
        });
      }
    }
  }

  void _nextPage() {
    _imageTimer?.cancel();
    if (_currentPage < _rules.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _startImageSlideshow();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'How To Play',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _rules.length,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  final rule = _rules[index];
                  Widget content;
                  if (rule.containsKey('images')) {
                    final images = rule['images'] as List<String>;
                    content = AnimatedSwitcher(
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        width: 200,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            images[_currentImageIndex],
                            key: ValueKey<int>(_currentImageIndex),
                            width: 200,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  } else {
                    content = Text(
                      rule['emoji'] as String,
                      style: const TextStyle(fontSize: 48),
                    );
                  }

                  return Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          content,
                          const SizedBox(height: 20),
                          Text(
                            rule['text'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _rules.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentPage == index ? AppColors.primary : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nextPage,
              child: Text(_currentPage == _rules.length - 1 ? 'Close' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}
