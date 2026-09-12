import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

enum FiltroEstado { todos, activos, inactivos }

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoService _service = ProductoService();
  late Future<List<Producto>> _futureProductos;

  FiltroEstado _filtroActual = FiltroEstado.todos;

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

  List<Producto> _aplicarFiltro(List<Producto> lista) {
    switch (_filtroActual) {
      case FiltroEstado.activos:
        return lista.where((p) => p.estado == true).toList();
      case FiltroEstado.inactivos:
        return lista.where((p) => p.estado == false).toList();
      case FiltroEstado.todos:
        return lista;
    }
  }

  String _etiquetaFiltro(FiltroEstado filtro) {
    switch (filtro) {
      case FiltroEstado.todos:
        return 'Todos';
      case FiltroEstado.activos:
        return 'Activos';
      case FiltroEstado.inactivos:
        return 'Inactivos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario de Productos'),
        actions: [
          PopupMenuButton<FiltroEstado>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar por estado',
            initialValue: _filtroActual,
            onSelected: (nuevoFiltro) {
              setState(() => _filtroActual = nuevoFiltro);
            },
            itemBuilder: (context) => FiltroEstado.values.map((filtro) {
              return PopupMenuItem(
                value: filtro,
                child: Row(
                  children: [
                    Icon(
                      _filtroActual == filtro ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: _filtroActual == filtro ? Colors.indigo : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Text(_etiquetaFiltro(filtro)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_filtroActual != FiltroEstado.todos)
            Container(
              width: double.infinity,
              color: Colors.indigo.withOpacity(0.08),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: Colors.indigo),
                  const SizedBox(width: 6),
                  Text(
                    'Mostrando: ${_etiquetaFiltro(_filtroActual)}',
                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _filtroActual = FiltroEstado.todos),
                    child: const Text('Limpiar', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Producto>>(
              future: _futureProductos,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final listaFiltrada = _aplicarFiltro(snapshot.data!);

                if (listaFiltrada.isEmpty) {
                  return Center(
                    child: Text('No hay productos "${_etiquetaFiltro(_filtroActual)}"'),
                  );
                }

                return ListView.builder(
                  itemCount: listaFiltrada.length,
                  itemBuilder: (ctx, i) {
                    final prod = listaFiltrada[i];
                    return ListTile(
                      leading: Icon(
                        prod.estado ? Icons.check_circle : Icons.cancel,
                        color: prod.estado ? Colors.green : Colors.grey,
                      ),
                      title: Text(
                        prod.nombre,
                        style: TextStyle(
                          decoration: prod.estado ? TextDecoration.none : TextDecoration.lineThrough,
                        ),
                      ),
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
          ),
        ],
      ),
    );
  }
}