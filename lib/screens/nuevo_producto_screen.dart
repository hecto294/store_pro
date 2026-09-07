import 'package:flutter/material.dart';
import '../models/producto.dart';

class NuevoProductoScreen extends StatefulWidget {
  const NuevoProductoScreen({super.key});

  @override
  State<NuevoProductoScreen> createState() => _NuevoProductoScreenState();
}

class _NuevoProductoScreenState extends State<NuevoProductoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  void _guardarProducto() {
    if (_formKey.currentState!.validate()) {
      final nuevoProducto = Producto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: _nombreController.text.trim(),
        precio: double.parse(_precioController.text.replaceAll(',', '.')),
        categoria: _categoriaController.text.trim(),
      );

      Navigator.pop(context, nuevoProducto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Nuevo Producto'),
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
              _campoTexto(
                controller: _nombreController,
                label: 'Nombre del producto',
                icono: Icons.shopping_bag,
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _campoTexto(
                controller: _precioController,
                label: 'Precio',
                icono: Icons.attach_money,
                tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'El precio es obligatorio';
                  }
                  final numero = double.tryParse(valor.replaceAll(',', '.'));
                  if (numero == null || numero <= 0) {
                    return 'Ingresa un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _campoTexto(
                controller: _categoriaController,
                label: 'Categoría',
                icono: Icons.category,
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'La categoría es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _guardarProducto,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Producto'),
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

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    required String? Function(String?) validator,
    TextInputType tipoTeclado = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: tipoTeclado,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.blue,
      decoration: InputDecoration(
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
      ),
    );
  }
}