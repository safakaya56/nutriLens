import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/food_item_model.dart';
import '../../providers/app_state.dart';

class ResultView extends StatefulWidget {
  final FoodAnalysisResult foodResult;
  final Uint8List? imageBytes;

  const ResultView({Key? key, required this.foodResult, this.imageBytes}) : super(key: key);

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  late String _selectedMeal;
  double _portionMultiplier = 1.0;
  bool _isSaving = false;

  final List<String> _meals = ["Kahvaltı", "Öğle", "Akşam", "Ara Öğün"];

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.foodResult.mealType.isNotEmpty ? widget.foodResult.mealType : "Öğle";
  }

  void _saveMealToDiary() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSaving = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.saveMeal(
      widget.foodResult,
      _selectedMeal,
      _portionMultiplier,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? "✓ Öğün veritabanına başarıyla kaydedildi!" : "Öğün kaydedilemedi, tekrar deneyin."),
        backgroundColor: success ? NutriLensTheme.primaryEmerald : Colors.redAccent,
      ),
    );
    if (success) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentCalories = (widget.foodResult.calories * _portionMultiplier).round();
    final double currentProtein = (widget.foodResult.proteinG * _portionMultiplier);
    final double currentCarbs = (widget.foodResult.carbsG * _portionMultiplier);
    final double currentFat = (widget.foodResult.fatG * _portionMultiplier);
    final int currentGram = (widget.foodResult.portionG * _portionMultiplier).round();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : NutriLensTheme.background,
      appBar: AppBar(
        title: Text("Öğün Detayı / Doğrulama", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.white : NutriLensTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Üst Yemek Kartı Görseli ---
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: isDark ? const Color(0xFF1E293B) : Colors.grey[300],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: widget.imageBytes != null
                                ? Image.memory(
                                    widget.imageBytes!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: isDark ? NutriLensTheme.primaryMint.withOpacity(0.3) : NutriLensTheme.primaryEmerald.withOpacity(0.85),
                                    child: const Center(
                                      child: Icon(Icons.restaurant, color: Colors.white54, size: 80),
                                    ),
                                  ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 16,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.foodResult.foodName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    widget.foodResult.source == "camera" ? "Fotoğraf Taraması" : "Barkod Taraması",
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- Öğün Seçici Haplar ---
                    Row(
                      children: _meals.map((meal) {
                        final isSelected = meal == _selectedMeal;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedMeal = meal),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald)
                                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald)
                                      : (isDark ? const Color(0xFF334155) : NutriLensTheme.cardBorder),
                                ),
                              ),
                              child: Text(
                                meal,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : NutriLensTheme.textDark),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // --- 4'lü Makro Özet Kutuları ---
                    Row(
                      children: [
                        _buildMacroTile(context, "Kalori", "$currentCalories", "kcal", isDark ? Colors.white : NutriLensTheme.textDark),
                        const SizedBox(width: 10),
                        _buildMacroTile(context, "Protein", "${currentProtein.toStringAsFixed(0)}", "g", NutriLensTheme.proteinCoral, isDot: true),
                        const SizedBox(width: 10),
                        _buildMacroTile(context, "Karb", "${currentCarbs.toStringAsFixed(0)}", "g", NutriLensTheme.carbAmber, isDot: true),
                        const SizedBox(width: 10),
                        _buildMacroTile(context, "Yağ", "${currentFat.toStringAsFixed(0)}", "g", NutriLensTheme.fatIndigo, isDot: true),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- Porsiyon Ayarı Kartı ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : NutriLensTheme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Porsiyon Ayarı",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Ölçeğe göre besin değerleri güncellenir",
                                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isDark ? const Color(0xFF334155) : NutriLensTheme.cardBorder),
                                ),
                                child: Text(
                                  "$currentGram  g",
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),

                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: NutriLensTheme.primaryMint,
                              inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              thumbColor: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
                              overlayColor: NutriLensTheme.primaryMint.withOpacity(0.2),
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                            ),
                            child: Slider(
                              value: _portionMultiplier,
                              min: 0.5,
                              max: 2.0,
                              divisions: 3,
                              onChanged: (val) => setState(() => _portionMultiplier = val),
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("0.5x", style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : NutriLensTheme.textSecondary)),
                              Text("1.0x (Standart)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald)),
                              Text("1.5x", style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : NutriLensTheme.textSecondary)),
                              Text("2.0x", style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : NutriLensTheme.textSecondary)),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- Ayrıştırılan Bileşenler Kartı ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : NutriLensTheme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Ayrıştırılan Bileşenler",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark),
                              ),
                              Text(
                                "${widget.foodResult.ingredients.length} Malzeme",
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          ...widget.foodResult.ingredients.map((ing) {
                            final ingGram = (ing.portionG * _portionMultiplier).round();
                            final ingCal = (ing.calories * _portionMultiplier).round();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF881337).withOpacity(0.3) : const Color(0xFFFFF1F2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.flatware, color: NutriLensTheme.proteinCoral, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(ing.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark)),
                                          const SizedBox(height: 2),
                                          Text("$ingGram g • $ingCal kcal", style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.edit_outlined, color: isDark ? Colors.white38 : NutriLensTheme.textMuted, size: 20),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            // En Alttaki Sabit "Öğünü Kaydet" Butonu
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _saveMealToDiary,
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text("Öğünü Kaydet", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMacroTile(BuildContext context, String label, String value, String unit, Color color, {bool isDot = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? const Color(0xFF334155) : NutriLensTheme.cardBorder),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isDot) ...[
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                ],
                Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(unit, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : NutriLensTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
