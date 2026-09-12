import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import 'login_view.dart';


class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "badge": "AI Görsel Tanıma",
      "badgeIcon": Icons.auto_awesome_rounded,
      "titleNormal": "Fotoğrafla ",
      "titleHighlight": "Tanı",
      "desc": "Tabağınızın fotoğrafını çekin, saniyeler içinde tüm besin değerlerini ve porsiyonları görün.",
      "image": "assets/images/onboarding_ai.png",
    },
    {
      "badge": "Hızlı Tarama",
      "badgeIcon": Icons.qr_code_scanner_rounded,
      "titleNormal": "Barkod ",
      "titleHighlight": "Okut",
      "desc": "Paketli gıdaların barkodunu anında tarayın, makro ve kalori dökümünü tek dokunuşla keşfedin.",
      "image": "assets/images/onboarding_barcode.png",
    },
    {
      "badge": "Kişisel Kalori",
      "badgeIcon": Icons.center_focus_strong_rounded,
      "titleNormal": "Hedefini ",
      "titleHighlight": "Belirle",
      "desc": "Metabolizmanıza ve kilonuza göre günlük kalori ve makro dengenizi otomatik hesaplayın.",
      "image": "assets/images/onboarding_goal.png",
    },
  ];

  void _navigateToLogin() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.completeOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Fullscreen PageView Slider
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              final item = _onboardingData[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Arka Plan Görseli
                  Image.asset(
                    item["image"],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1E293B),
                      child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 64),
                    ),
                  ),

                  // Karanlık Degrade Katmanları (Okunabilirlik için)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.88),
                          Colors.black.withOpacity(0.98),
                        ],
                        stops: const [0.0, 0.25, 0.5, 0.8, 1.0],
                      ),
                    ),
                  ),

                  // Alt İçerik Alanı
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Rozet (Badge)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: NutriLensTheme.primaryMint.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: NutriLensTheme.primaryMint.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item["badgeIcon"] as IconData,
                                color: NutriLensTheme.primaryMint,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item["badge"] as String,
                                style: const TextStyle(
                                  color: NutriLensTheme.primaryMint,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Başlık (İki renkli)
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                            children: [
                              TextSpan(text: item["titleNormal"] as String),
                              TextSpan(
                                text: item["titleHighlight"] as String,
                                style: const TextStyle(
                                  color: NutriLensTheme.primaryMint,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Açıklama Metni
                        Text(
                          item["desc"] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Indicator Dots + Aksiyon Butonu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  _onboardingData.length,
                                  (i) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: _currentPage == i ? 24 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _currentPage == i
                                          ? NutriLensTheme.primaryMint
                                          : Colors.white.withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (_currentPage == _onboardingData.length - 1) ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NutriLensTheme.primaryMint,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                elevation: 4,
                              ),
                              onPressed: _navigateToLogin,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Başlayın",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // 2. Üst Header Bar (NutriLens Kapsülü & Atla Butonu)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sol: NutriLens Kapsülü
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              "assets/images/logo.png",
                              width: 22,
                              height: 22,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: NutriLensTheme.primaryMint,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.center_focus_strong, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "NutriLens",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sağ: Atla > Butonu
                    GestureDetector(
                      onTap: _navigateToLogin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "Atla",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

