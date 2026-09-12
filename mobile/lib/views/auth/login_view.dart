import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import 'onboarding_profile_view.dart';
import '../dashboard/dashboard_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isSignUp = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  void _submit() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();

    // 1. Boş Veri Kontrolü
    if (email.isEmpty || password.isEmpty || (_isSignUp && fullName.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("⚠️ Lütfen tüm alanları doldurun."),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // 2. E-posta Format Kontrolü
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("⚠️ Geçerli bir e-posta adresi girin (Örn: isim@domain.com)."),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // 3. Şifre Uzunluğu Kontrolü
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("⚠️ Şifreniz en az 6 karakter olmalıdır."),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    bool success;
    if (_isSignUp) {
      success = await appState.register(email, password, fullName);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("✓ Kayıt başarılı! Profil ayarlarınız oluşturuluyor..."),
            backgroundColor: NutriLensTheme.primaryEmerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingProfileView()),
        );
        return;
      }
    } else {
      success = await appState.login(email, password);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("✓ Giriş başarılı! Yönlendiriliyorsunuz..."),
            backgroundColor: NutriLensTheme.primaryEmerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardView()),
        );
        return;
      }
    }

    if (!success && mounted) {
      final errorMsg = appState.authError ?? (_isSignUp ? "Kayıt işlemi başarısız." : "Giriş başarısız. Bilgilerinizi kontrol edin.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ $errorMsg"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isLoading = appState.isLoading;

    return Scaffold(
      backgroundColor: NutriLensTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header (İkon kaldırıldı, sade & modern başlık)
                const Text(
                  "NutriLens",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: NutriLensTheme.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Yapay Zeka Destekli Besin & Kalori Takibi",
                  style: TextStyle(fontSize: 14, color: NutriLensTheme.textSecondary),
                ),

                const SizedBox(height: 32),

                // Modern Kapsül Tab Switcher (Giriş Yap / Kayıt Ol)
                Container(
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isSignUp = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: !_isSignUp ? NutriLensTheme.primaryEmerald : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: !_isSignUp
                                  ? [
                                      BoxShadow(
                                        color: NutriLensTheme.primaryEmerald.withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                "Giriş Yap",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: !_isSignUp ? Colors.white : NutriLensTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isSignUp = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _isSignUp ? NutriLensTheme.primaryEmerald : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: _isSignUp
                                  ? [
                                      BoxShadow(
                                        color: NutriLensTheme.primaryEmerald.withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                "Kayıt Ol",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _isSignUp ? Colors.white : NutriLensTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Form Girdileri (Modern Kart Yapısında)
                if (_isSignUp) ...[
                  _buildTextField("Adınız Soyadınız", _fullNameController, Icons.person_outline_rounded),
                  const SizedBox(height: 14),
                ],

                _buildTextField("E-posta Adresi", _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _buildTextField("Şifre", _passwordController, Icons.lock_outline_rounded, obscureText: true),

                const SizedBox(height: 32),

                // Gönder Butonu
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NutriLensTheme.primaryEmerald,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                      elevation: 2,
                    ),
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isSignUp ? "Hesap Oluştur ve Başla" : "Giriş Yap",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                            ],
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NutriLensTheme.cardBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: NutriLensTheme.textDark, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          icon: Icon(icon, color: NutriLensTheme.textSecondary, size: 22),
          hintText: label,
          hintStyle: const TextStyle(color: NutriLensTheme.textMuted, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
