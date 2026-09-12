import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/diary_model.dart';
import '../../providers/app_state.dart';
import '../scanner/scanner_view.dart';
import '../profile/profile_view.dart';
import '../components/quick_manual_add_dialog.dart';
import '../components/weekly_summary_sheet.dart';
import '../settings/settings_view.dart';


class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // --- Güvenli Türkçe Sayı Biçimlendirme ---
  String _formatNumber(num value) {
    try {
      return NumberFormat('#,###', 'tr_TR').format(value);
    } catch (_) {
      return value.toStringAsFixed(0);
    }
  }

  // --- Güvenli Türkçe Tarih Metni Oluşturucu ---
  String _formatDateTurkish(DateTime date, {bool includeYear = false}) {
    const months = [
      "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
      "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"
    ];
    final day = date.day;
    final monthIndex = (date.month - 1).clamp(0, 11);
    final month = months[monthIndex];
    if (includeYear) {
      return "$day $month ${date.year}";
    }
    return "$day $month";
  }

  // --- Seçili Tarihe Göre Haftalık Gün Listesi Oluştur ---
  List<Map<String, String>> _generateWeekDaysAround(DateTime focusedDate) {
    final monday = focusedDate.subtract(Duration(days: focusedDate.weekday - 1));
    final dayNames = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];
    List<Map<String, String>> list = [];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      list.add({
        "day": dayNames[i],
        "date": date.day.toString(),
        "full_date": DateFormat('yyyy-MM-dd').format(date),
      });
    }
    return list;
  }

  String _formatSelectedDateHeader(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      final yesterdayStr = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

      if (dateStr == todayStr) return "Bugün (${_formatDateTurkish(date)})";
      if (dateStr == yesterdayStr) return "Dün (${_formatDateTurkish(date)})";
      return _formatDateTurkish(date, includeYear: true);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final userProfile = appState.userProfile;
    final summary = appState.dailySummary;

    final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String selectedDate = appState.selectedDate;
    final DateTime focusedDateTime = DateTime.tryParse(selectedDate) ?? DateTime.now();
    final bool isToday = selectedDate == todayStr;
    final bool isPastDate = selectedDate.compareTo(todayStr) < 0;

    final calendarDays = _generateWeekDaysAround(focusedDateTime);

    final String userName = userProfile?.fullName ?? "Kullanıcı";
    final int targetCal = summary?.targetCalories ?? userProfile?.dailyTargetCalories ?? 2100;
    final int consumedCal = summary?.consumedCalories ?? 0;
    final int remainingCal = summary?.remainingCalories ?? targetCal;

    final double proteinConsumed = summary?.proteinConsumed ?? 0;
    final double proteinTarget = summary?.proteinTarget ?? userProfile?.proteinG.toDouble() ?? 140;

    final double carbsConsumed = summary?.carbsConsumed ?? 0;
    final double carbsTarget = summary?.carbsTarget ?? userProfile?.carbsG.toDouble() ?? 210;

    final double fatConsumed = summary?.fatConsumed ?? 0;
    final double fatTarget = summary?.fatTarget ?? userProfile?.fatG.toDouble() ?? 65;

    final meals = summary?.meals ?? [];

    return Scaffold(
      backgroundColor: NutriLensTheme.bg(context),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => appState.refreshDailySummary(),
              color: NutriLensTheme.primaryEmerald,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Üst Başlık & Selamlama ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Merhaba $userName",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: NutriLensTheme.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isToday
                                  ? "Bugün dengeli beslenme yolundasın"
                                  : isPastDate
                                      ? "${_formatDateTurkish(focusedDateTime)} özeti"
                                      : "Gelecek gün planı",
                              style: TextStyle(
                                fontSize: 14,
                                color: NutriLensTheme.textSec(context),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: NutriLensTheme.cardBg(context),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: NutriLensTheme.cardBorderColor(context),
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.settings_rounded, color: NutriLensTheme.accentColor(context), size: 22),
                                tooltip: "Ayarlar",
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SettingsView()),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 16),

                    // --- Tarih Navigasyonu ve Takvim Başlığı ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                              icon: Icon(Icons.chevron_left_rounded, color: NutriLensTheme.textPrimary(context), size: 28),
                              onPressed: () {
                                final prev = focusedDateTime.subtract(const Duration(days: 1));
                                appState.setSelectedDate(DateFormat('yyyy-MM-dd').format(prev));
                              },
                            ),
                            Text(
                              _formatSelectedDateHeader(selectedDate),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NutriLensTheme.textPrimary(context)),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                              icon: Icon(Icons.chevron_right_rounded, color: NutriLensTheme.textPrimary(context), size: 28),
                              onPressed: () {
                                final next = focusedDateTime.add(const Duration(days: 1));
                                appState.setSelectedDate(DateFormat('yyyy-MM-dd').format(next));
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.calendar_month_rounded, color: NutriLensTheme.primaryEmerald, size: 22),
                              tooltip: "Tarih Seç",
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: focusedDateTime,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  appState.setSelectedDate(DateFormat('yyyy-MM-dd').format(picked));
                                }
                              },
                            ),
                            if (!isToday)
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  appState.setSelectedDate(todayStr);
                                },
                                child: const Text(
                                  "Bugün",
                                  style: TextStyle(color: NutriLensTheme.primaryEmerald, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              )
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 10),

                    // --- 7 Günlük Dinamik Takvim Hapları (Bugün Vurgulu & Büyük) ---
                    SizedBox(
                      height: 78,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: calendarDays.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final dayItem = calendarDays[index];
                          final isSelected = dayItem["full_date"] == selectedDate;
                          final isTodayItem = dayItem["full_date"] == todayStr;

                          return GestureDetector(
                            onTap: () {
                              appState.setSelectedDate(dayItem["full_date"]!);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isTodayItem ? 58 : 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? NutriLensTheme.primaryMint
                                    : isTodayItem
                                        ? (NutriLensTheme.isDark(context) ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                                        : NutriLensTheme.cardBg(context),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? NutriLensTheme.primaryMint
                                      : isTodayItem
                                          ? (NutriLensTheme.isDark(context) ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald)
                                          : NutriLensTheme.cardBorderColor(context),
                                  width: isTodayItem ? 2.0 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: NutriLensTheme.primaryMint.withOpacity(0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : isTodayItem
                                        ? [
                                            BoxShadow(
                                              color: NutriLensTheme.primaryEmerald.withOpacity(0.15),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayItem["day"]!,
                                    style: TextStyle(
                                      fontSize: isTodayItem ? 13 : 12,
                                      color: isSelected
                                          ? Colors.white
                                          : isTodayItem
                                              ? (NutriLensTheme.isDark(context) ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald)
                                              : NutriLensTheme.textSec(context),
                                      fontWeight: isTodayItem || isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dayItem["date"]!,
                                    style: TextStyle(
                                      fontSize: isTodayItem ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : isTodayItem
                                              ? (NutriLensTheme.isDark(context) ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald)
                                              : NutriLensTheme.textPrimary(context),
                                    ),
                                  ),
                                  if (isTodayItem && !isSelected) ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: NutriLensTheme.isDark(context) ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        "Bugün",
                                        style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ] else if (isSelected) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- Dairesel Kalori Gösterge Kartı ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: NutriLensTheme.cardBg(context),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: NutriLensTheme.cardBorderColor(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // Dairesel Gauge
                          SizedBox(
                            width: 190,
                            height: 190,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 180,
                                  height: 180,
                                  child: CircularProgressIndicator(
                                    value: targetCal > 0 ? (consumedCal / targetCal).clamp(0.0, 1.0) : 0.0,
                                    strokeWidth: 16,
                                    backgroundColor: NutriLensTheme.chipBg(context),
                                    valueColor: const AlwaysStoppedAnimation<Color>(NutriLensTheme.primaryMint),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _formatNumber(remainingCal),
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: NutriLensTheme.textPrimary(context),
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isPastDate ? "GÜN SONU KALAN" : "KCAL KALAN",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: NutriLensTheme.textSec(context),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Alt Bilgi Etiketi
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Hedef: ", style: TextStyle(color: NutriLensTheme.textSec(context), fontSize: 13)),
                              Text(_formatNumber(targetCal), style: TextStyle(color: NutriLensTheme.textPrimary(context), fontWeight: FontWeight.bold, fontSize: 14)),
                              Text("  •  ", style: TextStyle(color: NutriLensTheme.textSec(context))),
                              Text("Alınan: ", style: TextStyle(color: NutriLensTheme.textSec(context), fontSize: 13)),
                              Text(_formatNumber(consumedCal), style: const TextStyle(color: NutriLensTheme.primaryMint, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),

                          const SizedBox(height: 20),
                          Divider(color: NutriLensTheme.cardBorderColor(context), height: 1),
                          const SizedBox(height: 16),

                          // Makro İlerleme Barları
                          Row(
                            children: [
                              _buildMacroColumn("Protein", "${proteinConsumed.round()} / ${proteinTarget.round()}g", proteinTarget > 0 ? proteinConsumed / proteinTarget : 0, NutriLensTheme.proteinCoral),
                              _buildMacroColumn("Karb", "${carbsConsumed.round()} / ${carbsTarget.round()}g", carbsTarget > 0 ? carbsConsumed / carbsTarget : 0, NutriLensTheme.carbAmber),
                              _buildMacroColumn("Yağ", "${fatConsumed.round()} / ${fatTarget.round()}g", fatTarget > 0 ? fatConsumed / fatTarget : 0, NutriLensTheme.fatIndigo),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- 💧 Su Takibi Kartı (Water Tracker) ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: NutriLensTheme.cardBg(context),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: NutriLensTheme.cardBorderColor(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: NutriLensTheme.isDark(context) ? const Color(0xFF0369A1).withOpacity(0.3) : const Color(0xFFE0F2FE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.water_drop_rounded,
                                      color: Color(0xFF38BDF8),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Günlük Su Takibi",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: NutriLensTheme.textPrimary(context),
                                        ),
                                      ),
                                      Text(
                                        "${appState.waterMl} / ${appState.waterTargetMl} ml",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF38BDF8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.refresh_rounded, color: NutriLensTheme.textSec(context), size: 20),
                                tooltip: "Su Tüketimini Sıfırla",
                                onPressed: () => appState.resetWater(),
                              )
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Su İlerleme Barı
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (appState.waterMl / appState.waterTargetMl).clamp(0.0, 1.0),
                              minHeight: 10,
                              backgroundColor: NutriLensTheme.isDark(context) ? const Color(0xFF0369A1).withOpacity(0.2) : const Color(0xFFE0F2FE),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Hızlı Ekleme Butonları
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: NutriLensTheme.isDark(context) ? const Color(0xFF0369A1) : const Color(0xFFBAE6FD)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  onPressed: () => appState.addWater(250),
                                  icon: const Icon(Icons.local_drink_rounded, size: 18, color: Color(0xFF38BDF8)),
                                  label: const Text("+250 ml", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: NutriLensTheme.isDark(context) ? const Color(0xFF0369A1) : const Color(0xFFBAE6FD)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  onPressed: () => appState.addWater(500),
                                  icon: const Icon(Icons.local_drink_rounded, size: 18, color: Color(0xFF38BDF8)),
                                  label: const Text("+500 ml", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- 📊 Haftalık Özet Raporu Kart Butonu ---
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NutriLensTheme.isDark(context) ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        onPressed: () => WeeklySummarySheet.show(context),
                        icon: const Icon(Icons.analytics_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          "Haftalık Kalori & Makro Özeti",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- Öğünler ---
                    Text(
                      isToday ? "Bugünkü Öğünler" : "${_formatDateTurkish(focusedDateTime)} Öğünleri",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: NutriLensTheme.textPrimary(context),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Öğün Kartları Listesi (Tüm Eklenen Yemekleri Kapsar)
                    ..._buildDynamicMealCards(context, meals),
                  ],
                ),
              ),
            ),

            // --- Yüzen Alt Navigasyon Barı (Bottom Floating Nav) ---
            Positioned(
              left: 24,
              right: 24,
              bottom: 20,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: NutriLensTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: NutriLensTheme.cardBorderColor(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Ana Sayfa Sekmesi
                    GestureDetector(
                      onTap: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.home_rounded, color: NutriLensTheme.primaryMint, size: 24),
                          SizedBox(height: 2),
                          Text(
                            "Ana Sayfa",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: NutriLensTheme.primaryMint,
                            ),
                          )
                        ],
                      ),
                    ),

                    // Orta "+" Yiyecek Ekle Butonu (Elevated FAB)
                    GestureDetector(
                      onTap: () => _showAddMealActionSheet(context),
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: NutriLensTheme.isDark(context) ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: NutriLensTheme.primaryMint.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),

                    // Profil Sekmesi
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileView()),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline_rounded, color: NutriLensTheme.textSec(context), size: 24),
                          const SizedBox(height: 2),
                          Text(
                            "Profil",
                            style: TextStyle(
                              fontSize: 11,
                              color: NutriLensTheme.textSec(context),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showAddMealActionSheet(BuildContext context, [String? targetMeal]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: isDark ? Colors.white30 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              targetMeal != null ? "$targetMeal Ekle" : "Yemek Ekle",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: NutriLensTheme.primaryMint.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(Icons.camera_alt_rounded, color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald, size: 22),
              ),
              title: Text("Kamera & Görsel Tanıma", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : NutriLensTheme.textDark)),
              subtitle: Text("Yapay zeka veya barkod ile anında tarayın", style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (context) => ScannerView(targetMeal: targetMeal)));
              },
            ),
            Divider(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF78350F).withOpacity(0.4) : const Color(0xFFFEF3C7), shape: BoxShape.circle),
                child: const Icon(Icons.edit_note_rounded, color: Color(0xFFF59E0B), size: 22),
              ),
              title: Text("Manuel Yiyecek Ekle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : NutriLensTheme.textDark)),
              subtitle: Text("Yiyecek adını ve kalorisini elle girin", style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                QuickManualAddDialog.show(
                  context,
                  initialMealType: targetMeal,
                  onSave: (food, mealType, multiplier) {
                    Provider.of<AppState>(context, listen: false).saveMeal(food, mealType, multiplier);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicMealCards(BuildContext context, List<MealItem> meals) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mealCategories = [
      {"name": "Kahvaltı", "icon": "🍳"},
      {"name": "Öğle", "icon": "🥗"},
      {"name": "Akşam", "icon": "🍖"},
      {"name": "Ara Öğün", "icon": "🍎"},
    ];

    List<Widget> list = [];

    for (var cat in mealCategories) {
      final name = cat["name"]!;
      final icon = cat["icon"]!;

      final categoryMeals = meals.where((m) {
        final mType = m.mealType.toLowerCase();
        if (name == "Kahvaltı") return mType.contains("kahvaltı") || mType.contains("breakfast");
        if (name == "Öğle") return mType.contains("öğle") || mType.contains("lunch");
        if (name == "Akşam") return mType.contains("akşam") || mType.contains("dinner");
        return mType.contains("ara") || mType.contains("snack");
      }).toList();

      final int totalCatCalories = categoryMeals.fold(0, (sum, item) => sum + item.calories);
      final bool hasMeals = categoryMeals.isNotEmpty && totalCatCalories > 0;

      list.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: isDark ? const Color(0xFF334155) : NutriLensTheme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark),
                      ),
                      if (hasMeals) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? NutriLensTheme.primaryMint.withOpacity(0.2) : NutriLensTheme.primaryLightMint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "$totalCatCalories kcal",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald),
                          ),
                        ),
                      ],
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline_rounded, color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald, size: 24),
                    tooltip: "$name Ekle",
                    onPressed: () => _showAddMealActionSheet(context, name),
                  ),
                ],
              ),

              if (hasMeals) ...[
                const SizedBox(height: 10),
                Divider(color: isDark ? const Color(0xFF334155) : NutriLensTheme.cardBorder, height: 1),
                const SizedBox(height: 10),
                ...categoryMeals.map((meal) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.fiber_manual_record, size: 8, color: NutriLensTheme.primaryMint),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    meal.foodName,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : NutriLensTheme.textDark),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${meal.calories} kcal",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary),
                          ),
                        ],
                      ),
                    )),
              ] else ...[
                const SizedBox(height: 4),
                Text(
                  "Henüz yemek eklenmedi",
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : NutriLensTheme.textMuted),
                ),
              ]
            ],
          ),
        ),
      );
    }
    return list;
  }

  Widget _buildMacroColumn(String label, String value, double progress, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : NutriLensTheme.textDark)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary)),
        ],
      ),
    );
  }
}
