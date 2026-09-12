import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';

class WeeklySummarySheet extends StatefulWidget {
  const WeeklySummarySheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WeeklySummarySheet(),
    );
  }

  @override
  State<WeeklySummarySheet> createState() => _WeeklySummarySheetState();
}

class _WeeklySummarySheetState extends State<WeeklySummarySheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadWeeklySummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final weeklyData = appState.weeklyData;
    final isLoading = appState.isWeeklyLoading;

    double avgCalories = 0;
    if (weeklyData.isNotEmpty) {
      final total = weeklyData.fold<int>(0, (sum, item) => sum + (item["calories"] as int? ?? 0));
      avgCalories = total / weeklyData.length;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: NutriLensTheme.primaryMint.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Haftalık Kalori & Makro Özet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : NutriLensTheme.textDark,
                      ),
                    ),
                    Text(
                      "Son 7 günlük beslenme dengeniz",
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Average Banner Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? NutriLensTheme.primaryMint.withOpacity(0.15) : NutriLensTheme.primaryLightMint.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: NutriLensTheme.primaryMint.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Haftalık Günlük Ortalama",
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${avgCalories.round()} kcal / gün",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.analytics_rounded,
                  color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
                  size: 36,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Chart or Loading
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: NutriLensTheme.primaryMint),
                  )
                : weeklyData.isEmpty
                    ? Center(
                        child: Text("Haftalık veri bulunamadı.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black)),
                      )
                    : Column(
                        children: [
                          Text(
                            "7 Günlük Alınan Kalori Dağılımı",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : NutriLensTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final maxCal = weeklyData.fold<int>(2000, (maxVal, item) {
                                  final cal = item["calories"] as int? ?? 0;
                                  return cal > maxVal ? cal : maxVal;
                                });

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: weeklyData.map((item) {
                                    final cal = item["calories"] as int? ?? 0;
                                    final dayName = item["dayName"] as String? ?? "";
                                    final ratio = (cal / maxCal).clamp(0.05, 1.0);
                                    final barHeight = constraints.maxHeight * 0.7 * ratio;

                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "$cal",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white70 : NutriLensTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 400),
                                          width: 24,
                                          height: barHeight,
                                          decoration: BoxDecoration(
                                            color: cal > 0
                                                ? NutriLensTheme.primaryMint
                                                : (isDark ? const Color(0xFF0F172A) : Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          dayName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white : NutriLensTheme.textDark,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                );
                              },
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
