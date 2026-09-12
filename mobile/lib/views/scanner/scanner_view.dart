import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../result/result_view.dart';
import '../../models/food_item_model.dart';
import '../components/quick_manual_add_dialog.dart';


class ScannerView extends StatefulWidget {
  final String? targetMeal;
  const ScannerView({Key? key, this.targetMeal}) : super(key: key);

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  int _selectedSegment = 0; // 0: Yemek Fotoğrafı, 1: Barkod
  bool _isFlashOn = false;
  bool _isAnalyzing = false;
  bool _isBarcodeHandled = false; // Bir defa barkod okununca tekrar okumayı engeller
  
  late final MobileScannerController _scannerController;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  // --- Akıllı Öğün Türü Hesabı ---
  String _getSmartMealType() {
    if (widget.targetMeal != null && widget.targetMeal!.isNotEmpty) {
      return widget.targetMeal!;
    }
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) return "Kahvaltı";
    if (hour >= 11 && hour < 16) return "Öğle";
    if (hour >= 16 && hour < 22) return "Akşam";
    return "Ara Öğün";
  }

  // --- Flaş Aç/Kapa ---
  void _toggleFlash() async {
    try {
      await _scannerController.toggleTorch();
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      debugPrint("Torch toggle error: $e");
    }
  }

  // --- Harici Fotoğraf Seçimi (Galeri) ---
  Future<void> _pickFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile == null || !mounted) return;

      setState(() => _isAnalyzing = true);

      final bytes = await pickedFile.readAsBytes();
      final appState = Provider.of<AppState>(context, listen: false);

      final FoodAnalysisResult? result = await appState.apiClient.analyzeFoodImageBytes(bytes, pickedFile.name);

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      if (result != null) {
        if (!result.isFood || result.errorMessage != null) {
          _showNonFoodWarning(result.errorMessage ?? "Fotoğrafta tüketilebilir bir gıda bulunamadı. Lütfen bir öğün fotoğrafı çekin.");
        } else {
          final smartMeal = _getSmartMealType();
          final updatedResult = result.copyWith(
            mealType: result.mealType.isNotEmpty ? result.mealType : smartMeal,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ResultView(foodResult: updatedResult, imageBytes: bytes)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Görsel analizi yapılamadı, lütfen tekrar deneyin.")),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isAnalyzing = false);
      debugPrint("Pick gallery error: $e");
    }
  }

  // --- Uygulama İçi Kamera Snapshot Çekimi (Harici Kamera Uygulamasına Yönlenmeden) ---
  Future<void> _takeInAppSnapshot() async {
    if (_isAnalyzing) return;
    try {
      setState(() => _isAnalyzing = true);

      Uint8List? bytes;
      try {
        final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          final ui.Image image = await boundary.toImage(pixelRatio: 1.5);
          final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            bytes = byteData.buffer.asUint8List();
          }
        }
      } catch (err) {
        debugPrint("In-app snapshot repaint boundary error: $err");
      }

      // Yedek olarak fallback (gerekirse)
      if (bytes == null) {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );
        if (pickedFile == null) {
          if (mounted) setState(() => _isAnalyzing = false);
          return;
        }
        bytes = await pickedFile.readAsBytes();
      }

      final appState = Provider.of<AppState>(context, listen: false);
      final FoodAnalysisResult? result = await appState.apiClient.analyzeFoodImageBytes(bytes, "snapshot.png");

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      if (result != null) {
        if (!result.isFood || result.errorMessage != null) {
          _showNonFoodWarning(result.errorMessage ?? "Fotoğrafta tüketilebilir bir gıda bulunamadı. Lütfen bir öğün fotoğrafı çekin.");
        } else {
          final smartMeal = _getSmartMealType();
          final updatedResult = result.copyWith(
            mealType: result.mealType.isNotEmpty ? result.mealType : smartMeal,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ResultView(foodResult: updatedResult, imageBytes: bytes)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Görsel analizi yapılamadı, lütfen tekrar deneyin.")),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isAnalyzing = false);
      debugPrint("Capture snapshot error: $e");
    }
  }

  // --- Canlı Otomatik Barkod Taraması ---
  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_selectedSegment != 1 || _isAnalyzing || _isBarcodeHandled) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    _isBarcodeHandled = true;
    setState(() => _isAnalyzing = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final result = await appState.apiClient.analyzeFoodBarcode(code);

    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    if (result != null) {
      if (!result.isFood || result.errorMessage != null) {
        _showNonFoodWarning(result.errorMessage ?? "'$code' barkodlu ürün bir gıda/içecek ürünü değildir.");
        await Future.delayed(const Duration(seconds: 2));
        _isBarcodeHandled = false;
      } else {
        final smartMeal = _getSmartMealType();
        final updatedResult = result.copyWith(
          mealType: result.mealType.isNotEmpty ? result.mealType : smartMeal,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ResultView(foodResult: updatedResult)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("'$code' barkodlu ürün bulunamadı."),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: "Manuel Ekle",
            textColor: Colors.amberAccent,
            onPressed: () {
              QuickManualAddDialog.show(
                context,
                onSave: (food, mealType, multiplier) {
                  appState.saveMeal(food, mealType, multiplier);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      _isBarcodeHandled = false;
    }
  }

  // --- Gıda Dışı Nesne / Uyarı Diyalogu ---
  void _showNonFoodWarning(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 28),
            SizedBox(width: 8),
            Text("Gıda Ürünü Değil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: NutriLensTheme.textDark, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NutriLensTheme.primaryEmerald,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Tamam", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- Manuel Barkod Girişi (Yedek Yöntem - Yalnızca Barkod Modunda Açılır) ---
  void _showBarcodeInputDialog() async {
    final TextEditingController barcodeController = TextEditingController(text: "8690504018001");

    final String? code = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Manuel Barkod Girin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: TextField(
          controller: barcodeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Örn: 8690504018001",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NutriLensTheme.primaryEmerald),
            onPressed: () => Navigator.pop(dialogContext, barcodeController.text.trim()),
            child: const Text("Sorgula", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );

    if (code != null && code.isNotEmpty && mounted) {
      final appState = Provider.of<AppState>(context, listen: false);
      setState(() => _isAnalyzing = true);
      final result = await appState.apiClient.analyzeFoodBarcode(code);

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      if (result != null) {
        if (!result.isFood || result.errorMessage != null) {
          _showNonFoodWarning(result.errorMessage ?? "'$code' barkodlu ürün bir gıda/içecek ürünü değildir.");
        } else {
          final smartMeal = _getSmartMealType();
          final updatedResult = result.copyWith(
            mealType: result.mealType.isNotEmpty ? result.mealType : smartMeal,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ResultView(foodResult: updatedResult)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Barkod bulunamadı veya sunucu yanıt vermedi.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Canlı Kamera Viewfinder Akışı (MobileScanner + RepaintBoundary)
          Positioned.fill(
            child: RepaintBoundary(
              key: _previewKey,
              child: MobileScanner(
                controller: _scannerController,
                onDetect: _onBarcodeDetected,
                errorBuilder: (context, error, child) {
                  return Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt_outlined, color: Colors.white38, size: 80),
                          SizedBox(height: 12),
                          Text(
                            "Kamera Başlatılamadı",
                            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Lütfen cihaz ayarlarından kamera iznini onaylayın.",
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Yükleniyor Göstergesi
          if (_isAnalyzing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.75),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: NutriLensTheme.primaryMint, strokeWidth: 3),
                    const SizedBox(height: 16),
                    Text(
                      _selectedSegment == 0 ? "Yapay Zeka Tabağınızı Analiz Ediyor..." : "Barkod Ürünü Sorgulanıyor...",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Besin değerleri ve kaloriler hesaplanıyor",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Kamera Kadraj Braketleri ve Odak Çerçevesi
          if (!_isAnalyzing)
            Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0, left: 0,
                      child: Container(width: 32, height: 32, decoration: const BoxDecoration(border: Border(top: BorderSide(color: NutriLensTheme.primaryMint, width: 4), left: BorderSide(color: NutriLensTheme.primaryMint, width: 4)), borderRadius: BorderRadius.only(topLeft: Radius.circular(16)))),
                    ),
                    Positioned(
                      top: 0, right: 0,
                      child: Container(width: 32, height: 32, decoration: const BoxDecoration(border: Border(top: BorderSide(color: NutriLensTheme.primaryMint, width: 4), right: BorderSide(color: NutriLensTheme.primaryMint, width: 4)), borderRadius: BorderRadius.only(topRight: Radius.circular(16)))),
                    ),
                    Positioned(
                      bottom: 0, left: 0,
                      child: Container(width: 32, height: 32, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: NutriLensTheme.primaryMint, width: 4), left: BorderSide(color: NutriLensTheme.primaryMint, width: 4)), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16)))),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(width: 32, height: 32, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: NutriLensTheme.primaryMint, width: 4), right: BorderSide(color: NutriLensTheme.primaryMint, width: 4)), borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)))),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedSegment == 0 ? "Tabağı çerçeveye hizalayın" : "Barkodu çerçeveye hizalayın",
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

          // 4. Üst Kontrol Butonları & Segment Seçici
          if (!_isAnalyzing)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.camera_alt_outlined, color: NutriLensTheme.primaryMint, size: 16),
                              SizedBox(width: 6),
                              Text("NutriLens Taraması", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleFlash,
                          icon: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: _isFlashOn ? NutriLensTheme.primaryMint : Colors.white,
                            size: 26,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Kayan Segment Seçici ([Yemek Fotoğrafı] | [Barkod])
                    Container(
                      width: 260,
                      height: 44,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSegment = 0;
                                  _isBarcodeHandled = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedSegment == 0 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.restaurant, size: 16, color: _selectedSegment == 0 ? NutriLensTheme.primaryEmerald : Colors.white70),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Yemek Fotoğrafı",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedSegment == 0 ? NutriLensTheme.primaryEmerald : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSegment = 1;
                                  _isBarcodeHandled = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedSegment == 1 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.qr_code_scanner, size: 16, color: _selectedSegment == 1 ? NutriLensTheme.primaryEmerald : Colors.white70),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Barkod",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedSegment == 1 ? NutriLensTheme.primaryEmerald : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Alt Kontroller (Galeri, Uygulama İçi Fotoğraf Deklanşörü, Manuel Barkod)
          if (!_isAnalyzing)
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Galeri Seçici
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 24),
                      onPressed: _pickFromGallery,
                    ),
                  ),

                  // Uygulama İçi Fotoğraf Çekimi Deklanşörü
                  GestureDetector(
                    onTap: _takeInAppSnapshot,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Manuel Barkod Giriş Butonu (Yalnızca Barkod Sekmesinde Gözükür)
                  if (_selectedSegment == 1)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 26),
                        onPressed: _showBarcodeInputDialog,
                      ),
                    )
                  else
                    const SizedBox(width: 50, height: 50),
                ],
              ),
            )
        ],
      ),
    );
  }
}

