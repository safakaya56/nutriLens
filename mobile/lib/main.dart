import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'providers/app_state.dart';
import 'views/auth/splash_view.dart';
import 'views/auth/login_view.dart';
import 'views/dashboard/dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('tr_TR', null);
  } catch (e) {
    debugPrint("Locale initialization error: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const NutriLensApp(),
    ),
  );
}

class NutriLensApp extends StatelessWidget {
  const NutriLensApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return MaterialApp(
      title: 'NutriLens',
      debugShowCheckedModeBanner: false,
      theme: NutriLensTheme.lightTheme,
      darkTheme: NutriLensTheme.darkTheme,
      themeMode: appState.themeMode,
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (appState.isLoading) {
      return const Scaffold(
        backgroundColor: NutriLensTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: NutriLensTheme.primaryEmerald),
        ),
      );
    }

    if (appState.isLoggedIn) {
      return const DashboardView();
    }

    if (appState.isFirstLaunch) {
      return const SplashView();
    }

    return const LoginView();
  }
}
