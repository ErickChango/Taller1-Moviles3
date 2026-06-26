import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/bienvenida.dart';
import 'screens/catalogo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mvmilqyfqwujofopwyec.supabase.co',
    anonKey: 'sb_publishable_G3VXFHkbyHnpNEIS61Se9g_AOMwXYFi',
  );

  runApp(const StreamFlixApp());
}

class StreamFlixApp extends StatelessWidget {
  const StreamFlixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StreamFlix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F1A),
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFFEC4899),
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // Usuario ya logueado — intentar recuperar edad del metadata
      final age = (session.user.userMetadata?['age'] as num?)?.toInt() ?? 18;
      return CatalogScreen(userAge: age);
    }

    return const WelcomeScreen();
  }
}
