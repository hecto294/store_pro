import 'package:flutter/material.dart';
import '../models/usuario.dart';

class NuevoUsuarioScreen extends StatefulWidget {
  const NuevoUsuarioScreen({super.key});

  @override
  State<NuevoUsuarioScreen> createState() => _NuevoUsuarioScreenState();
}

class _NuevoUsuarioScreenState extends State<NuevoUsuarioScreen> {
  // GlobalKey: le permite al formulario validarse a sí mismo desde afuera.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Expresión regular simple: exige texto, luego "@", luego más texto,
  // luego "." y más texto (formato básico de correo electrónico).
  final RegExp _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _guardarUsuario() {
    if (_formKey.currentState!.validate()) {
      final nuevoUsuario = Usuario(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
      );

      Navigator.pop(context, nuevoUsuario);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Nuevo Usuario'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                style: const TextStyle(color: Colors.white),
                decoration: _decoracionCampo('Nombre', Icons.person),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _decoracionCampo('Correo electrónico', Icons.email),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'El correo es obligatorio';
                  }
                  if (!_emailRegex.hasMatch(valor.trim())) {
                    return 'Ingresa un correo válido (ej: nombre@dominio.com)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _guardarUsuario,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Usuario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracionCampo(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icono, color: Colors.blue),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2F3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}