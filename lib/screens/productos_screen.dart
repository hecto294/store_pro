import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/producto.dart';
import '../models/categoria.dart';
import '../services/producto_service.dart';
import '../services/categoria_service.dart';
import '../widgets/role_guard_widget.dart';
import '../widgets/offline_banner.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoService _service = ProductoService();
  final CategoriaService _categoriaService = CategoriaService();

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

  // --- Formulario para crear un nuevo producto ---
  Future<void> _mostrarDialogoCrear() async {
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final stockCtrl = TextEditingController();

    List<Categoria> categorias = [];
    Categoria? categoriaSeleccionada;

    try {
      final todas = await _categoriaService.getCategorias();
      categorias = todas.where((c) => c.estado == true).toList();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar las categorías')),
      );
      return;
    }

    if (categorias.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay categorías activas. Crea o activa una primero')),
      );
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Nuevo producto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: precioCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Precio'),
                    ),
                    TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Categoria>(
                      initialValue: categoriaSeleccionada,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: categorias
                          .map((c) => DropdownMenuItem(value: c, child: Text(c.nombre)))
                          .toList(),
                      onChanged: (val) => setDialogState(() => categoriaSeleccionada = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final precio = double.tryParse(precioCtrl.text.trim());
                    final stock = int.tryParse(stockCtrl.text.trim());

                    if (nombreCtrl.text.trim().isEmpty ||
                        precio == null ||
                        stock == null ||
                        categoriaSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Completa todos los campos correctamente')),
                      );
                      return;
                    }

                    final ok = await _service.crearProducto(
                      nombreCtrl.text.trim(),
                      precio,
                      stock,
                      categoriaSeleccionada!.id,
                    );

                    if (ok) {
                      Navigator.pop(ctx);
                      _cargarProductos();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al crear el producto')),
                      );
                    }
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarEliminar(Producto prod) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro que deseas eliminar "${prod.nombre}"?'),
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
      final ok = await _service.eliminarProducto(prod.id);
      if (ok) {
        _cargarProductos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el producto')),
        );
      }
    }
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
            onPressed: _mostrarDialogoCrear,
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

            trailing: RoleGuardWidget(
              allowedRoles: const ['admin'],
              fallback: Chip(
                label: Text(prod.estado ? 'Activo' : 'Inactivo'),
                backgroundColor: prod.estado ? Colors.green.shade50 : Colors.grey.shade200,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: prod.estado,
                    onChanged: (val) async {
                      await _service.cambiarEstado(prod.id);
                      _cargarProductos();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmarEliminar(prod),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}