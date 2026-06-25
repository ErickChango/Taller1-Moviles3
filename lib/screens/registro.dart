import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'catalogo.dart';
import 'login.dart';

const _primary = Color(0xFF7C3AED);
const _secondary = Color(0xFFEC4899);
const _fieldBg = Color(0xFF1E1E2E);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _register() {
    final int age = int.tryParse(_ageCtrl.text.trim()) ?? 18;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CatalogScreen(userAge: age)),
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
                  'Crear cuenta',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 6),
              const Text('Únete a StreamFlix hoy 🎬',
                  style: TextStyle(color: Colors.white54, fontSize: 15)),
              const SizedBox(height: 40),

              _buildField(controller: _nameCtrl, label: 'Nombre completo', icon: Icons.person_outline),
              const SizedBox(height: 18),
              _buildField(controller: _emailCtrl, label: 'Correo electrónico',
                  icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 18),
              _buildField(controller: _ageCtrl, label: 'Edad',
                  icon: Icons.cake_outlined, keyboardType: TextInputType.number),
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
              const SizedBox(height: 12),

              // Info edad
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _primary.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF7C3AED), size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tu edad define qué películas puedes ver. El contenido +18 solo está disponible para mayores de edad.',
                        style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_primary, _secondary]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Crear cuenta',
                        style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes cuenta? ', style: TextStyle(color: Colors.white54)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text('Inicia sesión',
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
