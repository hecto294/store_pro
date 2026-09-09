import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final AuthService _authService = AuthService();
  late Future<Usuario?> _futureUsuario;

  static const Color _acento = Color(0xFF3B5BFF);

  @override
  void initState() {
    super.initState();
    _futureUsuario = _authService.getPerfil();
  }

  void _cerrarSesion() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: FutureBuilder<Usuario?>(
          future: _futureUsuario,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: _acento));
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Error al cargar datos del usuario'));
            }

            final usuario = snapshot.data!;
            final esAdmin = usuario.role == 'admin';
            final inicial = usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : 'U';

            return SingleChildScrollView(
              child: Column(
                children: [
                  // --- Header con degradado y avatar ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_acento, Color(0xFF1E3AAA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white,
                          child: Text(
                            inicial,
                            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: _acento),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          usuario.nombre,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          usuario.email,
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: esAdmin ? Colors.amber.shade200 : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                esAdmin ? Icons.admin_panel_settings : Icons.badge_outlined,
                                size: 15,
                                color: esAdmin ? Colors.brown.shade700 : _acento,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                usuario.role.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: esAdmin ? Colors.brown.shade700 : _acento,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Tarjeta con información adicional ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _filaInfo(Icons.badge, 'ID de usuario', usuario.id?.toString() ?? '—'),
                          const Divider(height: 24),
                          _filaInfo(
                            Icons.verified_user,
                            'Permisos',
                            esAdmin
                                ? 'Acceso total (crear, editar, activar/desactivar)'
                                : 'Solo lectura de catálogo',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Botón cerrar sesión ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red.shade200),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _cerrarSesion,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _filaInfo(IconData icono, String etiqueta, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 20, color: _acento),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 2),
              Text(valor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}