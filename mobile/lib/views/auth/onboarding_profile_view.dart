import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../dashboard/dashboard_view.dart';

class OnboardingProfileView extends StatefulWidget {
  const OnboardingProfileView({Key? key}) : super(key: key);

  @override
  State<OnboardingProfileView> createState() => _OnboardingProfileViewState();
}

class _OnboardingProfileViewState extends State<OnboardingProfileView> {
  final TextEditingController _ageController = TextEditingController(text: "24");
  final TextEditingController _heightController = TextEditingController(text: "180");
  final TextEditingController _weightController = TextEditingController(text: "78");

  String _selectedGoal = "weight_loss";
  String _selectedActivity = "moderate";

  void _saveAndProceed() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final age = int.tryParse(_ageController.text) ?? 24;
    final height = double.tryParse(_heightController.text) ?? 180.0;
    final weight = double.tryParse(_weightController.text) ?? 78.0;

    final profileData = {
      "age": age,
      "height_cm": height,
      "weight_kg": weight,
      "gender": "male",
      "goal": _selectedGoal,
      "activity_level": _selectedActivity,
    };

    final success = await appState.updateProfile(profileData);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✓ Profil başarıyla oluşturuldu!"),
          backgroundColor: NutriLensTheme.primaryEmerald,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AppState>(context).isLoading;

    return Scaffold(
      backgroundColor: NutriLensTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Başlık
              const Text(
                "Fiziki Profilinizi Oluşturun",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: NutriLensTheme.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                "Mifflin-St Jeor yöntemiyle günlük ideal kalori hedefinizi hesaplıyoruz.",
                style: TextStyle(fontSize: 14, color: NutriLensTheme.textSecondary),
              ),

              const SizedBox(height: 24),

              // Yaş, Boy, Kilo
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

              // Hedef Seçimi
              const Text("HEDEFİNİZ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NutriLensTheme.textSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 12),

              _buildGoalCard("weight_loss", "Kilo Ver", "-400 kcal açık", "Sağlıklı ve dengeli yağ yakımı", Icons.trending_down),
              const SizedBox(height: 10),
              _buildGoalCard("maintain", "Kiloyu Koru", "Denge", "Mevcut kütleyi koruma", Icons.balance),
              const SizedBox(height: 10),
              _buildGoalCard("weight_gain", "Kilo Al / Kas Kazan", "+350 kcal fazla", "Temiz hacim artışı", Icons.fitness_center),

              const SizedBox(height: 24),

              // Aktivite Seviyesi
              const Text("AKTİVİTE SEVİYESİ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NutriLensTheme.textSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 12),

              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
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

              const SizedBox(height: 32),

              // Kaydet ve Başla Butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NutriLensTheme.primaryEmerald,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : _saveAndProceed,
                  child: isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text("Profilimi Kaydet ve Başla", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputTile(String label, TextEditingController controller, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NutriLensTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: NutriLensTheme.textSecondary)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: NutriLensTheme.textDark),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                  ),
                ),
                if (unit.isNotEmpty) Text(unit, style: const TextStyle(fontSize: 12, color: NutriLensTheme.textMuted)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(String keyName, String title, String badgeText, String subtitle, IconData icon) {
    final isSelected = _selectedGoal == keyName;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = keyName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? NutriLensTheme.primaryEmerald : NutriLensTheme.cardBorder, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? NutriLensTheme.primaryEmerald : Colors.transparent,
                border: Border.all(color: isSelected ? NutriLensTheme.primaryEmerald : NutriLensTheme.textMuted, width: 2),
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NutriLensTheme.textDark)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: isSelected ? const Color(0xFFE6F7F0) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                        child: Text(badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? NutriLensTheme.primaryEmerald : NutriLensTheme.textSecondary)),
                      )
                    ],
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: NutriLensTheme.textSecondary)),
                ],
              ),
            ),
            Icon(icon, color: isSelected ? NutriLensTheme.primaryEmerald : NutriLensTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySegment(String label, String keyName) {
    final isSelected = _selectedActivity == keyName;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedActivity = keyName),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? NutriLensTheme.primaryEmerald : NutriLensTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
