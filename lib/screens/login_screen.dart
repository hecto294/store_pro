import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'perfil_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: "admin@storepro.com");
  final _passCtrl = TextEditingController(text: "123456");
  final _authService = AuthService();
  bool _isLoading = false;
  bool _ocultarPassword = true;

  static const Color _acento = Color(0xFF3B5BFF);

  void _ejecutarLogin() async {
    setState(() => _isLoading = true);
    bool exito = await _authService.login(_emailCtrl.text, _passCtrl.text);
    setState(() => _isLoading = false);

    if (exito && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PerfilScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales o servidor incorrectos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- Logo / ícono con degradado ---
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_acento, Color(0xFF1E3AAA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _acento.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.storefront, color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'StorePro',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Inicia sesión para continuar',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // --- Tarjeta blanca con el formulario ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: const Icon(Icons.mail_outline, color: _acento),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passCtrl,
                          obscureText: _ocultarPassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline, color: _acento),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _ocultarPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: _acento))
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.login),
                                label: const Text('Ingresar a la App', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: _ejecutarLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _acento,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Tarjeta con credenciales de prueba (conserva los 2 perfiles) ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _acento.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _acento.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.info_outline, size: 16, color: _acento),
                            SizedBox(width: 6),
                            Text(
                              'CREDENCIALES DE PRUEBA',
                              style: TextStyle(fontWeight: FontWeight.bold, color: _acento, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _filaCredencial(
                          icono: Icons.admin_panel_settings,
                          rol: 'Admin',
                          email: 'admin@storepro.com',
                          password: '123456',
                        ),
                        const SizedBox(height: 8),
                        _filaCredencial(
                          icono: Icons.badge_outlined,
                          rol: 'Vendedor',
                          email: 'vendedor@storepro.com',
                          password: '123456',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filaCredencial({
    required IconData icono,
    required String rol,
    required String email,
    required String password,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        // Al tocar la fila, autocompleta los campos con esas credenciales.
        setState(() {
          _emailCtrl.text = email;
          _passCtrl.text = password;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icono, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$rol: $email',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            const Icon(Icons.touch_app, size: 14, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}