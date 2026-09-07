import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/user_service.dart';
import 'nuevo_usuario_screen.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final UserService _userService = UserService();
  late Future<List<Usuario>> _futureUsuarios;
  final List<Usuario> _usuariosLocales = [];

  @override
  void initState() {
    super.initState();
    _futureUsuarios = _userService.fetchUsuarios();
  }

  Future<void> _abrirNuevoUsuario() async {
    final Usuario? usuarioCreado = await Navigator.push<Usuario>(
      context,
      MaterialPageRoute(builder: (context) => const NuevoUsuarioScreen()),
    );

    if (usuarioCreado != null) {
      setState(() {
        _usuariosLocales.add(usuarioCreado);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Servicio de Usuarios'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNuevoUsuario,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      // FutureBuilder reconstruye la UI según el estado del Future:
      // esperando, con error, o con datos ya listos.
      body: FutureBuilder<List<Usuario>>(
        future: _futureUsuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.hasData) {
            final usuarios = [...snapshot.data!, ..._usuariosLocales];

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFF2A2F3A)),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      usuario.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      usuario.email,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}