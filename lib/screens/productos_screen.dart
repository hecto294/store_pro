import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoService _service = ProductoService();
  late Future<List<Producto>> _futureProductos;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  void _cargarProductos() {
    setState(() {
      _futureProductos = _service.getProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario de Productos')),
      body: FutureBuilder<List<Producto>>(
        future: _futureProductos,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final lista = snapshot.data!;
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (ctx, i) {
              final prod = lista[i];
              return ListTile(
                leading: Icon(
                  prod.estado ? Icons.check_circle : Icons.cancel,
                  color: prod.estado ? Colors.green : Colors.grey,
                ),
                title: Text(prod.nombre, style: TextStyle(decoration: prod.estado ? TextDecoration.none : TextDecoration.lineThrough)),
                subtitle: Text('Precio: \$${prod.precio} | Stock: ${prod.stock}'),
                trailing: Switch(
                  value: prod.estado,
                  onChanged: (val) async {
                    await _service.cambiarEstado(prod.id);
                    _cargarProductos();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}