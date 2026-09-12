import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/food_item_model.dart';

class QuickManualAddDialog extends StatefulWidget {
  final String? initialFoodName;
  final String? initialMealType;
  final Function(FoodAnalysisResult food, String mealType, double multiplier) onSave;

  const QuickManualAddDialog({
    Key? key,
    this.initialFoodName,
    this.initialMealType,
    required this.onSave,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    String? initialFoodName,
    String? initialMealType,
    required Function(FoodAnalysisResult food, String mealType, double multiplier) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickManualAddDialog(
        initialFoodName: initialFoodName,
        initialMealType: initialMealType,
        onSave: onSave,
      ),
    );
  }

  @override
  State<QuickManualAddDialog> createState() => _QuickManualAddDialogState();
}

class _QuickManualAddDialogState extends State<QuickManualAddDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _calController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  late String _selectedMealType;
  double _portionG = 100.0;

  final List<Map<String, String>> _mealTypes = [
    {"key": "breakfast", "label": "Kahvaltı", "icon": "🍳"},
    {"key": "lunch", "label": "Öğle Yemeği", "icon": "🥗"},
    {"key": "dinner", "label": "Akşam Yemeği", "icon": "🍖"},
    {"key": "snack", "label": "Atıştırmalık", "icon": "🍎"},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialFoodName ?? "");
    _calController = TextEditingController(text: "250");
    _proteinController = TextEditingController(text: "10");
    _carbsController = TextEditingController(text: "30");
    _fatController = TextEditingController(text: "8");

    _selectedMealType = widget.initialMealType ?? "lunch";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _calController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final calories = int.tryParse(_calController.text.trim()) ?? 0;
      final protein = double.tryParse(_proteinController.text.trim()) ?? 0.0;
      final carbs = double.tryParse(_carbsController.text.trim()) ?? 0.0;
      final fat = double.tryParse(_fatController.text.trim()) ?? 0.0;

      final foodResult = FoodAnalysisResult(
        foodName: name,
        calories: calories,
        proteinG: protein,
        carbsG: carbs,
        fatG: fat,
        portionG: _portionG,
        source: 'manual',
        ingredients: [],
      );

      widget.onSave(foodResult, _selectedMealType, 1.0);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("'$name' günlüğe başarıyla eklendi."),
          backgroundColor: NutriLensTheme.primaryEmerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Handle
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

                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: NutriLensTheme.primaryMint.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
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
                            "Hızlı Manuel Yiyecek Ekle",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : NutriLensTheme.textDark,
                            ),
                          ),
                          Text(
                            "Bulunamayan yiyecekleri elle ekleyebilirsiniz.",
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : NutriLensTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Öğün Seçimi kapsülleri
                Text("Öğün Seçin", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : NutriLensTheme.textDark)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _mealTypes.map((item) {
                    final isSelected = _selectedMealType == item["key"];
                    return ChoiceChip(
                      label: Text("${item["icon"]} ${item["label"]}"),
                      selected: isSelected,
                      selectedColor: isDark ? NutriLensTheme.primaryMint.withOpacity(0.25) : NutriLensTheme.primaryLightMint,
                      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? (isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald) : (isDark ? Colors.white70 : NutriLensTheme.textDark),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedMealType = item["key"]!);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Yiyecek Adı
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: "Yiyecek Adı",
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : NutriLensTheme.textSecondary),
                    hintText: "Örn: Izgara Tavuk Göğsü",
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                    prefixIcon: Icon(Icons.restaurant_menu_rounded, color: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: isDark ? const BorderSide(color: Color(0xFF334155)) : BorderSide.none),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Lütfen bir ad girin" : null,
                ),
                const SizedBox(height: 14),

                // Kalori (kcal)
                TextFormField(
                  controller: _calController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: "Kalori (kcal)",
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : NutriLensTheme.textSecondary),
                    prefixIcon: const Icon(Icons.local_fire_department_rounded, color: Colors.orange),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: isDark ? const BorderSide(color: Color(0xFF334155)) : BorderSide.none),
                  ),
                  validator: (v) => (v == null || int.tryParse(v.trim()) == null) ? "Geçerli bir kalori girin" : null,
                ),
                const SizedBox(height: 14),

                // Makrolar Row (Protein, Karbonhidrat, Yağ)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _proteinController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: "Protein (g)",
                          labelStyle: TextStyle(color: isDark ? Colors.white70 : NutriLensTheme.textSecondary),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDark ? const BorderSide(color: Color(0xFF334155)) : BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _carbsController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: "Karb (g)",
                          labelStyle: TextStyle(color: isDark ? Colors.white70 : NutriLensTheme.textSecondary),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDark ? const BorderSide(color: Color(0xFF334155)) : BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _fatController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: "Yağ (g)",
                          labelStyle: TextStyle(color: isDark ? Colors.white70 : NutriLensTheme.textSecondary),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDark ? const BorderSide(color: Color(0xFF334155)) : BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Ekle Butonu
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? NutriLensTheme.primaryMint : NutriLensTheme.primaryEmerald,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    ),
                    onPressed: _submit,
                    icon: const Icon(Icons.add_task_rounded, color: Colors.white),
                    label: const Text(
                      "Günlüğe Ekle",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
