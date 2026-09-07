import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/fake_api_service.dart';
import 'nuevo_producto_screen.dart';
import 'usuarios_screen.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final FakeApiService _apiService = FakeApiService();
  late Future<List<Producto>> _futureProductos;
  final List<Producto> _productosLocales = [];

  @override
  void initState() {
    super.initState();
    _futureProductos = _apiService.obtenerProductos();
  }

  Future<void> _abrirNuevoProducto() async {
    final Producto? productoCreado = await Navigator.push<Producto>(
      context,
      MaterialPageRoute(builder: (context) => const NuevoProductoScreen()),
    );

    if (productoCreado != null) {
      setState(() {
        _productosLocales.add(productoCreado);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${productoCreado.nombre} agregado ✅'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _irAUsuarios() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UsuariosScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('StorePro Fake API'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Botón en el AppBar para ir a la pantalla de Usuarios.
          IconButton(
            onPressed: _irAUsuarios,
            icon: const Icon(Icons.people),
            tooltip: 'Ver usuarios',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNuevoProducto,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Producto>>(
        future: _futureProductos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar productos: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.hasData) {
            final productos = [...snapshot.data!, ..._productosLocales];

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final prod = productos[index];
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
                      child: Icon(Icons.shopping_bag, color: Colors.white),
                    ),
                    title: Text(
                      prod.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      prod.categoria,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Text(
                      '\$${prod.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
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