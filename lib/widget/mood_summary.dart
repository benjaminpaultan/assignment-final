import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../logic/mood_controller.dart';

class MoodSummaryChart extends StatelessWidget {
  final MoodController controller;
  const MoodSummaryChart({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.getWeeklyPercentages();
    final int total = controller.moods.length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: [
              const Text("Weekly Vibe", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
              const SizedBox(height: 30),
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("$total", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                      Text("TOTAL", style: TextStyle(fontSize: 10, color: Colors.grey[400], letterSpacing: 2, fontWeight: FontWeight.bold)),
                    ])),
                    PieChart(
                      PieChartData(
                        sectionsSpace: 8,
                        centerSpaceRadius: 70,
                        sections: data.entries.map((e) => PieChartSectionData(
                          value: e.value,
                          title: '',
                          radius: 25,
                          color: _getColor(e.key),
                          badgeWidget: _Badge(e.key),
                          badgePositionPercentageOffset: 1.1,
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: data.entries.map((e) => _buildChip(e.key, e.value)).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.indigo[400]!, Colors.indigo[600]!]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [Icon(Icons.auto_awesome, color: Colors.white, size: 20), SizedBox(width: 8), Text("PERSONAL INSIGHT", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2))]),
              const SizedBox(height: 10),
              Text(controller.getDynamicEncouragement(), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String emoji, double val) => Container(
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
    child: Row(children: [Text(emoji), const SizedBox(width: 8), Text("${val.toStringAsFixed(0)}%", style: const TextStyle(fontWeight: FontWeight.bold))]),
  );

  Color _getColor(String emoji) {
    if (emoji == '🤩') return const Color(0xFF6366F1);
    if (emoji == '😊') return const Color(0xFFFFD54F);
    if (emoji == '😔') return const Color(0xFFFF8A65);
    return Colors.grey;
  }
}

class _Badge extends StatelessWidget {
  final String emoji;
  const _Badge(this.emoji);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(6),
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
    child: Text(emoji, style: const TextStyle(fontSize: 16)),
  );
}