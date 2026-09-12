import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  String _selectedGoal = "weight_loss";
  String _selectedActivity = "moderate";

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AppState>(context, listen: false).userProfile;
    _ageController = TextEditingController(text: (profile?.age ?? 24).toString());
    _heightController = TextEditingController(text: (profile?.heightCm ?? 180.0).round().toString());
    _weightController = TextEditingController(text: (profile?.weightKg ?? 78.0).round().toString());
    _selectedGoal = profile?.goal ?? "weight_loss";
    _selectedActivity = profile?.activityLevel ?? "moderate";
  }

  void _saveProfile() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final age = int.tryParse(_ageController.text) ?? 24;
    final height = double.tryParse(_heightController.text) ?? 180.0;
    final weight = double.tryParse(_weightController.text) ?? 78.0;

    final profileData = {
      "age": age,
      "height_cm": height,
      "weight_kg": weight,
      "gender": appState.userProfile?.gender ?? "male",
      "goal": _selectedGoal,
      "activity_level": _selectedActivity,
    };

    final success = await appState.updateProfile(profileData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "✓ Profil ve kalori hedefleri güncellendi!" : "Güncelleme başarısız, tekrar deneyin."),
          backgroundColor: success ? NutriLensTheme.primaryEmerald : Colors.redAccent,
        ),
      );
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<AppState>(context).userProfile;
    final bmr = userProfile?.bmr ?? 1790;
    final tdee = userProfile?.tdee ?? 2774;
    final targetCal = userProfile?.dailyTargetCalories ?? 2374;
    final proteinG = userProfile?.proteinG ?? 178;
    final carbsG = userProfile?.carbsG ?? 267;
    final fatG = userProfile?.fatG ?? 66;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : NutriLensTheme.background,
      appBar: AppBar(
        title: Text("Fiziksel Profil & Hedef", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.white : NutriLensTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vücut Bilgileri Başlığı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("VÜCUT BİLGİLERİ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary, letterSpacing: 0.5)),
                  Text("Metrik Sistem", style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : NutriLensTheme.textMuted)),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildInputTile("Yaş", _ageController, ""),
                  const SizedBox(width: 12),
                  _buildInputTile("Boy", _heightController, "cm"),
                  const SizedBox(width: 12),
                  _buildInputTile("Kilo", _weightController, "kg"),
                ],
              ),

              const SizedBox(height: 24),

              // Hedefiniz
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("HEDEFİNİZ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary, letterSpacing: 0.5)),
                  Text("Tek Seçim", style: TextStyle(fontSize: 12, color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),

              _buildGoalCard(
                keyName: "weight_loss",
                title: "Kilo Ver",
                badgeText: "-400 kcal açık",
                subtitle: "Sağlıklı ve dengeli yağ yakımı",
                icon: Icons.trending_down,
              ),
              const SizedBox(height: 12),

              _buildGoalCard(
                keyName: "maintain",
                title: "Kiloyu Koru",
                badgeText: "Denge",
                subtitle: "Mevcut kütleyi ve zindeliği koruma",
                icon: Icons.balance,
              ),
              const SizedBox(height: 12),

              _buildGoalCard(
                keyName: "weight_gain",
                title: "Kilo Al / Kas Kazan",
                badgeText: "+350 kcal fazla",
                subtitle: "Temiz hacim ve hipertrofi artışı",
                icon: Icons.fitness_center,
              ),

              const SizedBox(height: 24),

              // Aktivite Seviyesi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("AKTİVİTE SEVİYESİ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary, letterSpacing: 0.5)),
                  Text("PAL Faktörü", style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : NutriLensTheme.textMuted)),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildActivitySegment("Masa Başı", "sedentary"),
                    _buildActivitySegment("Orta Aktif", "moderate"),
                    _buildActivitySegment("Çok Hareketli", "active"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Günlük Önerilen Hedef Kutusu
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                            Icon(Icons.verified_outlined, color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald, size: 20),
                            const SizedBox(width: 6),
                            Text("GÜNLÜK ÖNERİLEN HEDEF", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text("Mifflin-St Jeor", style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text("$targetCal", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald)),
                        const SizedBox(width: 6),
                        Text("kcal / gün", style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text("BMR: $bmr kcal  •  TDEE: $tdee kcal", style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary)),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${proteinG}g P (%30)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark)),
                        Text("${carbsG}g K (%45)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark)),
                        Text("${fatG}g Y (%25)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Row(
                        children: [
                          Expanded(flex: 30, child: Container(height: 8, color: NutriLensTheme.primaryMint)),
                          Expanded(flex: 45, child: Container(height: 8, color: NutriLensTheme.carbAmber)),
                          Expanded(flex: 25, child: Container(height: 8, color: NutriLensTheme.fatIndigo)),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  onPressed: _saveProfile,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.save_outlined, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text("Bilgileri Güncelle ve Kaydet", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  "Hesaplanan değerler genel sağlık normlarına uygundur ve istendiğinde düzenlenebilir.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : NutriLensTheme.textMuted),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputTile(String label, TextEditingController controller, String unit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF334155) : NutriLensTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                  ),
                ),
                if (unit.isNotEmpty) Text(unit, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : NutriLensTheme.textMuted)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required String keyName,
    required String title,
    required String badgeText,
    required String subtitle,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedGoal == keyName;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = keyName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald)
                : (isDark ? const Color(0xFF334155) : NutriLensTheme.cardBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald)
                    : Colors.transparent,
                border: Border.all(
                    color: isSelected
                        ? (isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald)
                        : (isDark ? Colors.white38 : NutriLensTheme.textMuted),
                    width: 2),
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? NutriLensTheme.primaryMint.withOpacity(0.2) : const Color(0xFFE6F7F0))
                              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? (isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald)
                                : (isDark ? Colors.white70 : NutriLensTheme.textSecondary),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary)),
                ],
              ),
            ),
            Icon(icon, color: isSelected ? (isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald) : (isDark ? Colors.white38 : NutriLensTheme.textMuted), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySegment(String label, String keyName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedActivity == keyName;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedActivity = keyName),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? const Color(0xFF334155) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? (isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald) : (isDark ? Colors.white70 : NutriLensTheme.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
