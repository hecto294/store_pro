import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../services/categoria_service.dart';
import 'perfil_screen.dart';
import 'productos_screen.dart';

// Enum para representar las 3 opciones del filtro de forma segura y legible.
enum FiltroEstado { todos, activos, inactivos }

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final CategoriaService _service = CategoriaService();
  late Future<List<Categoria>> _futureCategorias;

  // Guarda cuál filtro está activo actualmente. Empieza mostrando todos.
  FiltroEstado _filtroActual = FiltroEstado.todos;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  void _cargarCategorias() {
    setState(() {
      _futureCategorias = _service.getCategorias();
    });
  }

  // Aplica el filtro seleccionado sobre la lista completa que ya llegó del servidor.
  // El filtrado es 100% local: no se vuelve a pedir nada a la API.
  List<Categoria> _aplicarFiltro(List<Categoria> lista) {
    switch (_filtroActual) {
      case FiltroEstado.activos:
        return lista.where((c) => c.estado == true).toList();
      case FiltroEstado.inactivos:
        return lista.where((c) => c.estado == false).toList();
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
        title: const Text('Categorías'),
        actions: [
          // --- Selector de filtro (PopupMenuButton) ---
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
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.inventory_2),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductosScreen())),
          )
        ],
      ),
      body: Column(
        children: [
          // --- Indicador visual de qué filtro está activo ---
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
            child: FutureBuilder<List<Categoria>>(
              future: _futureCategorias,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final listaFiltrada = _aplicarFiltro(snapshot.data!);

                if (listaFiltrada.isEmpty) {
                  return Center(
                    child: Text('No hay categorías "${_etiquetaFiltro(_filtroActual)}"'),
                  );
                }

                return ListView.builder(
                  itemCount: listaFiltrada.length,
                  itemBuilder: (ctx, i) {
                    final cat = listaFiltrada[i];
                    return ListTile(
                      title: Text(
                        cat.nombre,
                        style: TextStyle(
                          decoration: cat.estado ? TextDecoration.none : TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: Text(cat.descripcion),
                      trailing: Switch(
                        value: cat.estado,
                        onChanged: (val) async {
                          await _service.cambiarEstado(cat.id);
                          _cargarCategorias();
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