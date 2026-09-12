import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../auth/login_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  Future<void> _selectTime(
      BuildContext context, TimeOfDay initialTime, Function(TimeOfDay) onSelected) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: NutriLensTheme.primaryMint,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  ),
                  dialogBackgroundColor: const Color(0xFF1E293B),
                  timePickerTheme: TimePickerThemeData(
                    backgroundColor: const Color(0xFF1E293B),
                    hourMinuteColor: const Color(0xFF0F172A),
                    hourMinuteTextColor: Colors.white,
                    dayPeriodColor: const Color(0xFF0F172A),
                    dayPeriodTextColor: Colors.white,
                    dialBackgroundColor: const Color(0xFF0F172A),
                    dialHandColor: NutriLensTheme.primaryMint,
                    dialTextColor: Colors.white,
                    entryModeIconColor: NutriLensTheme.primaryMint,
                    helpTextStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: NutriLensTheme.primaryEmerald,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
                  timePickerTheme: const TimePickerThemeData(
                    hourMinuteColor: Color(0xFFE6F7F0),
                    hourMinuteTextColor: NutriLensTheme.primaryEmerald,
                    dialHandColor: NutriLensTheme.primaryEmerald,
                  ),
                ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSelected(picked);
    }
  }



  void _showAboutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: NutriLensTheme.primaryMint.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.center_focus_strong_rounded,
                size: 36,
                color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "NutriLens",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              "Sürüm 1.0.0",
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text(
              "Yapay zeka destekli besin analizi ve akıllı kalori takibi uygulaması.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Kapat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : NutriLensTheme.background,
      appBar: AppBar(
        title: Text("Ayarlar", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.white : NutriLensTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BİLDİRİMLER & ÖĞÜN SAATLERİ
            _buildSectionHeader(context, "BİLDİRİMLER & ÖĞÜN SAATLERİ"),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : NutriLensTheme.cardBorder,
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: NutriLensTheme.primaryMint,
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: NutriLensTheme.primaryMint.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.notifications_active_rounded, color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald, size: 20),
                    ),
                    title: Text("Öğün Hatırlatıcıları", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : NutriLensTheme.textDark)),
                    subtitle: Text("Belirlenen saatlerde bildirim gönderir", style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary)),
                    value: appState.mealRemindersEnabled,
                    onChanged: (val) => appState.setMealRemindersEnabled(val),
                  ),
                  if (appState.mealRemindersEnabled) ...[
                    Divider(height: 1, indent: 16, endIndent: 16, color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
                    _buildTimeTile(
                      context,
                      title: "Kahvaltı Saati",
                      icon: Icons.wb_twilight_rounded,
                      iconColor: Colors.amber,
                      time: appState.breakfastTime,
                      onTap: () => _selectTime(context, appState.breakfastTime, (t) => appState.setBreakfastTime(t)),
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
                    _buildTimeTile(
                      context,
                      title: "Öğle Yemeği Saati",
                      icon: Icons.wb_sunny_rounded,
                      iconColor: Colors.orange,
                      time: appState.lunchTime,
                      onTap: () => _selectTime(context, appState.lunchTime, (t) => appState.setLunchTime(t)),
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
                    _buildTimeTile(
                      context,
                      title: "Akşam Yemeği Saati",
                      icon: Icons.nights_stay_rounded,
                      iconColor: Colors.indigoAccent,
                      time: appState.dinnerTime,
                      onTap: () => _selectTime(context, appState.dinnerTime, (t) => appState.setDinnerTime(t)),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. GÖRÜNÜM & TEMA
            _buildSectionHeader(context, "GÖRÜNÜM & TEMA"),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : NutriLensTheme.cardBorder,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildThemeRadioTile(
                      context,
                      title: "Açık Tema",
                      icon: Icons.light_mode_rounded,
                      iconColor: Colors.amber,
                      value: ThemeMode.light,
                      groupValue: appState.themeMode,
                      onChanged: (val) => appState.setThemeMode(val!),
                    ),
                    Divider(height: 1, indent: 40, color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
                    _buildThemeRadioTile(
                      context,
                      title: "Koyu Tema",
                      icon: Icons.dark_mode_rounded,
                      iconColor: Colors.indigoAccent,
                      value: ThemeMode.dark,
                      groupValue: appState.themeMode,
                      onChanged: (val) => appState.setThemeMode(val!),
                    ),
                    Divider(height: 1, indent: 40, color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
                    _buildThemeRadioTile(
                      context,
                      title: "Sistem Teması",
                      icon: Icons.brightness_auto_rounded,
                      iconColor: NutriLensTheme.primaryMint,
                      value: ThemeMode.system,
                      groupValue: appState.themeMode,
                      onChanged: (val) => appState.setThemeMode(val!),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),



            // 4. UYGULAMA HAKKINDA
            _buildSectionHeader(context, "HAKKINDA"),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : NutriLensTheme.cardBorder,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: NutriLensTheme.primaryMint.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.info_outline_rounded, color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald, size: 20),
                ),
                title: Text("NutriLens Hakkında", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : NutriLensTheme.textDark)),
                subtitle: Text("Sürüm 1.0.0", style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary)),
                trailing: Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? Colors.white54 : Colors.grey),
                onTap: () => _showAboutDialog(context),
              ),
            ),

            const SizedBox(height: 32),

            // 5. ÇIKIŞ YAP
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50,
                  foregroundColor: isDark ? Colors.red.shade300 : Colors.red.shade700,
                  elevation: 0,
                  side: BorderSide(color: isDark ? Colors.red.shade700.withOpacity(0.5) : Colors.red.shade200, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  "Çıkış Yap",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  await appState.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginView()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF94A3B8) : NutriLensTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTimeTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

    return ListTile(
      leading: Icon(icon, color: iconColor, size: 20),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : NutriLensTheme.textDark)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? NutriLensTheme.primaryMint.withOpacity(0.2) : NutriLensTheme.primaryMint.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          formattedTime,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
            fontSize: 14,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildThemeRadioTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isDark ? Colors.white : NutriLensTheme.textDark,
                ),
              ),
            ),
            Radio<ThemeMode>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
            ),
          ],
        ),
      ),
    );
  }
}
