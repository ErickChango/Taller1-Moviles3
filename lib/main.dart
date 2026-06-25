import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/bienvenida.dart';
import 'screens/catalogo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mvmilqyfqwujofopwyec.supabase.co',
    anonKey: 'sb_publishable_G3VXFHkbyHnpNEIS61Se9g_AOMwXYFi',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Verifica si ya existe una sesión activa al abrir la app
    final session = Supabase.instance.client.auth.currentSession;
    final userAge = (Supabase.instance.client.auth.currentUser
            ?.userMetadata?['edad'] as num?)
        ?.toInt() ?? 0;

    return MaterialApp(
      title: 'StreamFlix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFFEC4899),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F1A),
          elevation: 0,
        ),
      ),
      // Si hay sesión activa va al catálogo, si no a la bienvenida
      home: session != null
          ? CatalogScreen(userAge: userAge)
          : const WelcomeScreen(),
    );
  }
}
