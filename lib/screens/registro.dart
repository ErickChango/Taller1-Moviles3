import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<void> _register() async {
    // Validaciones básicas
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty ||
        _ageCtrl.text.trim().isEmpty) {
      _showDialog('Campos incompletos', 'Por favor completá todos los campos.');
      return;
    }

    setState(() => _loading = true);
    try {
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        data: {
          'nick': _nameCtrl.text.trim(),
          'edad': int.tryParse(_ageCtrl.text.trim()) ?? 0,
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Tiempo de espera agotado. Verificá tu conexión a internet.'),
      );

      if (!mounted) return;

      if (res.session != null) {
        // Registro exitoso y sesión activa (email confirm desactivado)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else if (res.user != null) {
        // Registro exitoso pero requiere confirmación de email
        _showDialog(
          '¡Cuenta creada!',
          'Te enviamos un correo de confirmación a ${_emailCtrl.text.trim()}. '
          'Confirmá tu email y luego iniciá sesión.',
          onOk: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
        );
      } else {
        _showDialog('Error', 'No se pudo crear la cuenta. Intentá de nuevo.');
      }
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

  void _showDialog(String title, String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onOk?.call();
            },
            child: const Text('OK'),
          ),
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
                shaderCallback: (b) => const LinearGradient(colors: [_primary, _secondary]).createShader(b),
                child: const Text('Crear cuenta',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 6),
              const Text('Únete a StreamFlix hoy 🎬', style: TextStyle(color: Colors.white54, fontSize: 15)),
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
                controller: _passCtrl, label: 'Contraseña', icon: Icons.lock_outline, obscure: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                  onPressed: () => setState(() => _obscure = !_obscure),
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
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _loading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Crear cuenta',
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
                    onTap: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Text('Inicia sesión', style: TextStyle(color: _primary, fontWeight: FontWeight.bold)),
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
    required TextEditingController controller, required String label,
    required IconData icon, bool obscure = false,
    Widget? suffixIcon, TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller, obscureText: obscure, keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white38), suffixIcon: suffixIcon,
        filled: true, fillColor: _fieldBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }
}