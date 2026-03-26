import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/haptic/haptic_service.dart';
import '../core/theme/app_theme.dart';
import '../models/round_result.dart';
import '../services/game_engine.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(engine: engine)),
            SliverToBoxAdapter(child: _OverallStats(engine: engine)),
            SliverToBoxAdapter(
                child: _Chart(roundResults: engine.roundResults)),
            SliverToBoxAdapter(
                child: _RoundList(roundResults: engine.roundResults)),
            SliverToBoxAdapter(child: _Footer(engine: engine)),
          ],
        ),
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.engine});
  final GameEngine engine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Final Result 🏁',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${engine.totalRounds} rounds  •  ${engine.totalRounds * 60} seconds',
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Overall stats grid ────────────────────────────────────────────────────

class _OverallStats extends StatelessWidget {
  const _OverallStats({required this.engine});
  final GameEngine engine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          Row(children: [
            _StatCard(
              label: 'Answered',
              value: '${engine.totalQuestions}',
              icon: Icons.quiz_outlined,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Correct',
              value: '${engine.totalCorrect}',
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.success,
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _StatCard(
              label: 'Incorrect',
              value: '${engine.totalWrong}',
              icon: Icons.cancel_outlined,
              color: AppColors.danger,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Accuracy',
              value: '${engine.overallAccuracy.toStringAsFixed(1)}%',
              icon: Icons.percent_rounded,
              color: AppColors.secondary,
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _StatCard(
              label: 'Avg. Response',
              value: '${engine.overallAverageResponseTime}s',
              icon: Icons.speed_outlined,
              color: AppColors.warning,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Correct per Second',
              value: engine.overallCPS.toStringAsFixed(2),
              icon: Icons.flash_on_rounded,
              color: const Color(0xFF0891B2),
            ),
          ]),
        ],
      ),
    );
  }
}

// ─── Line Chart ────────────────────────────────────────────────────────────

class _Chart extends StatelessWidget {
  const _Chart({required this.roundResults});
  final List<RoundResult> roundResults;

  @override
  Widget build(BuildContext context) {
    if (roundResults.length < 2) return const SizedBox(height: 24);

    final spots = roundResults
        .map((r) => FlSpot(r.roundNumber.toDouble(), r.averageResponseTime))
        .toList();

    final maxY = roundResults
        .map((r) => r.averageResponseTime)
        .fold(0.0, (a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                'Avg. Response Time per Round',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toStringAsFixed(1)}s',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final n = v.toInt();
                          if (v != n.toDouble() ||
                              n < 1 ||
                              n > roundResults.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            'R$n',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 1,
                  maxX: roundResults.length.toDouble(),
                  minY: 0,
                  maxY: (maxY * 1.35).clamp(0.5, double.infinity),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: roundResults.length <= 30,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 3,
                          color: AppColors.primary,
                          strokeColor: Colors.white,
                          strokeWidth: 1.5,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.07),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Round list ────────────────────────────────────────────────────────────

class _RoundList extends StatelessWidget {
  const _RoundList({required this.roundResults});
  final List<RoundResult> roundResults;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary per Round',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...roundResults.map((r) => _RoundRow(result: r)),
        ],
      ),
    );
  }
}

// ─── Footer ────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({required this.engine});
  final GameEngine engine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
      child: ElevatedButton.icon(
        onPressed: () {
          HapticService.medium();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
            (_) => false,
          );
        },
        icon: const Icon(Icons.replay_rounded),
        label: const Text('PLAY AGAIN'),
      ),
    );
  }
}

// ─── Reusable widgets ──────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundRow extends StatelessWidget {
  const _RoundRow({required this.result});
  final RoundResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '${result.roundNumber}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.totalQuestions} answered  •  ${result.accuracy.toStringAsFixed(0)}% accuracy  •  ${result.correctPerSecond.toStringAsFixed(2)} CPS',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '✓ ${result.correctAnswers}  ✗ ${result.wrongAnswers}  •  Avg RT ${result.averageResponseTime}s',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
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
