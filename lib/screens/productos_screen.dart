import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../widgets/role_guard_widget.dart';
import '../widgets/offline_banner.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoService _service = ProductoService();

  List<Producto> _todosLosProductos = [];
  List<Producto> _productosFiltrados = [];

  bool _isLoading = true;
  String _errorMsg = '';

  String _searchQuery = '';
  String _filtroEstado = 'TODOS';

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      final lista = await _service.getProductos();
      setState(() {
        _todosLosProductos = lista;
        _aplicarFiltros();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Error al conectar con la API: $e';
        _isLoading = false;
      });
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _productosFiltrados = _todosLosProductos.where((prod) {
        final cumpleNombre = prod.nombre.toLowerCase().contains(_searchQuery.toLowerCase());

        bool cumpleEstado = true;
        if (_filtroEstado == 'ACTIVOS') cumpleEstado = prod.estado == true;
        if (_filtroEstado == 'INACTIVOS') cumpleEstado = prod.estado == false;

        return cumpleNombre && cumpleEstado;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return OfflineBannerWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventario de Productos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _cargarProductos,
            )
          ],
        ),

        // Solo el Admin ve este botón. Los vendedores NO lo ven.
        floatingActionButton: RoleGuardWidget(
          allowedRoles: const ['admin'],
          child: FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Formulario de Nuevo Producto (Acceso Admin)')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Producto'),
          ),
        ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) {
                  _searchQuery = val;
                  _aplicarFiltros();
                },
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _filtroEstado == 'TODOS',
                    onSelected: (_) {
                      _filtroEstado = 'TODOS';
                      _aplicarFiltros();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Solo Activos'),
                    selected: _filtroEstado == 'ACTIVOS',
                    onSelected: (_) {
                      _filtroEstado = 'ACTIVOS';
                      _aplicarFiltros();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Solo Inactivos'),
                    selected: _filtroEstado == 'INACTIVOS',
                    onSelected: (_) {
                      _filtroEstado = 'INACTIVOS';
                      _aplicarFiltros();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _cargarProductos,
                child: _buildBodyContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    // Estado 1: CARGANDO → Shimmer skeleton
    if (_isLoading) {
      return ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, _) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 70,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    // Estado 2: ERROR
    if (_errorMsg.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 12),
              Text(_errorMsg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar Conexión'),
                onPressed: _cargarProductos,
              )
            ],
          ),
        ),
      );
    }

    // Estado 3: VACÍO
    if (_productosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('No se encontraron productos', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    // Estado 4: ÉXITO — con RBAC en el trailing
    return ListView.builder(
      itemCount: _productosFiltrados.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (ctx, i) {
        final prod = _productosFiltrados[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: prod.estado ? Colors.green.shade100 : Colors.red.shade100,
              child: Icon(
                prod.estado ? Icons.check : Icons.block,
                color: prod.estado ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              prod.nombre,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: prod.estado ? TextDecoration.none : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text('Precio: \$${prod.precio} | Stock: ${prod.stock} un.'),

            // Admin ve Switch (puede cambiar estado). Vendedor ve Chip informativo.
            trailing: RoleGuardWidget(
              allowedRoles: const ['admin'],
              fallback: Chip(
                label: Text(prod.estado ? 'Activo' : 'Inactivo'),
                backgroundColor: prod.estado ? Colors.green.shade50 : Colors.grey.shade200,
              ),
              child: Switch(
                value: prod.estado,
                onChanged: (val) async {
                  await _service.cambiarEstado(prod.id);
                  _cargarProductos();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}