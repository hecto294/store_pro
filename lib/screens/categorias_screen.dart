import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/categoria.dart';
import '../services/categoria_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/role_guard_widget.dart';
import 'perfil_screen.dart';
import 'productos_screen.dart';

enum FiltroEstado { todos, activos, inactivos }

class AppColors {
  static const azulInicio = Color(0xFF4C63F6);
  static const azulFin = Color(0xFF2A3899);
  static const dorado = Color(0xFFF5C542);
  static const fondo = Color(0xFFF3F4F8);
  static const textoSecundario = Color(0xFF8A8D99);
}

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final CategoriaService _service = CategoriaService();
  late Future<List<Categoria>> _futureCategorias;

  // Por defecto se muestran todas (activas e inactivas).
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

  void _mostrarDialogoCrear() {
    final nombreCtrl = TextEditingController();
    final descripcionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Nueva categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: descripcionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nombreCtrl.text.trim().isEmpty) return;
                final ok = await _service.crearCategoria(
                  nombreCtrl.text.trim(),
                  descripcionCtrl.text.trim(),
                );
                if (ok) {
                  Navigator.pop(ctx);
                  _cargarCategorias();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al crear la categoría')),
                  );
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarEliminar(Categoria cat) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Seguro que deseas eliminar "${cat.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      final ok = await _service.eliminarCategoria(cat.id);
      if (ok) {
        _cargarCategorias();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar la categoría')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        title: const Text(
          'Categorías',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.azulInicio, AppColors.azulFin],
            ),
          ),
        ),
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
                      color: _filtroActual == filtro ? AppColors.azulInicio : Colors.grey,
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
      floatingActionButton: RoleGuardWidget(
        allowedRoles: const ['admin'],
        child: FloatingActionButton(
          onPressed: _mostrarDialogoCrear,
          backgroundColor: AppColors.azulInicio,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          if (_filtroActual != FiltroEstado.todos)
            Container(
              width: double.infinity,
              color: AppColors.dorado.withValues(alpha: 0.15),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: AppColors.azulFin),
                  const SizedBox(width: 6),
                  Text(
                    'Mostrando: ${_etiquetaFiltro(_filtroActual)}',
                    style: const TextStyle(
                      color: AppColors.azulFin,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _filtroActual = FiltroEstado.todos),
                    style: TextButton.styleFrom(foregroundColor: AppColors.azulFin),
                    child: const Text('Limpiar', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Categoria>>(
              future: _futureCategorias,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.azulInicio),
                  );
                }

                final listaFiltrada = _aplicarFiltro(snapshot.data!);

                if (listaFiltrada.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay categorías "${_etiquetaFiltro(_filtroActual)}"',
                      style: const TextStyle(color: AppColors.textoSecundario),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (ctx, i) {
                    final cat = listaFiltrada[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: (cat.estado ? AppColors.azulInicio : Colors.grey)
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.category,
                            color: cat.estado ? AppColors.azulInicio : Colors.grey,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          cat.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: cat.estado ? TextDecoration.none : TextDecoration.lineThrough,
                            color: cat.estado ? Colors.black87 : AppColors.textoSecundario,
                          ),
                        ),
                        subtitle: Text(
                          cat.descripcion,
                          style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                        ),
                        trailing: RoleGuardWidget(
                          allowedRoles: const ['admin'],
                          fallback: Chip(
                            label: Text(
                              cat.estado ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: cat.estado ? AppColors.azulFin : AppColors.textoSecundario,
                              ),
                            ),
                            backgroundColor: (cat.estado ? AppColors.azulInicio : Colors.grey)
                                .withValues(alpha: 0.12),
                            visualDensity: VisualDensity.compact,
                            side: BorderSide.none,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: cat.estado,
                                activeThumbColor: AppColors.dorado,
                                activeTrackColor: AppColors.dorado.withValues(alpha: 0.4),
                                onChanged: (val) async {
                                  await _service.cambiarEstado(cat.id);
                                  _cargarCategorias();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _confirmarEliminar(cat),
                              ),
                            ],
                          ),
                        ),
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