import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'catalogo.dart';
import 'registro.dart';

const _primary = Color(0xFF7C3AED);
const _secondary = Color(0xFFEC4899);
const _fieldBg = Color(0xFF1E1E2E);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _showDialog('Campos incompletos', 'Ingresá tu correo y contraseña.');
      return;
    }

    setState(() => _loading = true);
    try {
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Tiempo de espera agotado. Verificá tu conexión a internet.'),
      );
      final Session? session = res.session;
      final User? user = res.user;

      if (!mounted) return;

      if (session == null || user == null) {
        _showDialog(
          'Email no confirmado',
          'Revisá tu correo y confirmá tu cuenta antes de iniciar sesión.',
        );
        return;
      }

      final int userAge = (user.userMetadata?['edad'] as num?)?.toInt() ?? 0;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CatalogScreen(userAge: userAge)),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      _showDialog('Error', e.message);
    } catch (e) {
      if (!mounted) return;
      _showDialog('Error inesperado', e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [_primary, _secondary],
                ).createShader(b),
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 6),
              const Text('Bienvenido de nuevo 👋',
                  style: TextStyle(color: Colors.white54, fontSize: 15)),
              const SizedBox(height: 40),

              _buildField(controller: _emailCtrl, label: 'Correo electrónico',
                  icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 18),

              _buildField(
                controller: _passCtrl,
                label: 'Contraseña',
                icon: Icons.lock_outline,
                obscure: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_primary, _secondary]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Entrar',
                        style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta? ', style: TextStyle(color: Colors.white54)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text('Regístrate',
                        style: TextStyle(color: _primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white38),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _fieldBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }
}
