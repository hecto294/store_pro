import 'categoria.dart';

class Producto {
  final int id;
  final String nombre;
  final double precio;
  final int stock;
  final int categoriaId;
  final bool estado;
  final Categoria? categoria;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.categoriaId,
    required this.estado,
    this.categoria,
  });

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
    id: json['id'],
    nombre: json['nombre'],
    precio: (json['precio'] as num).toDouble(),
    stock: json['stock'],
    categoriaId: json['categoriaId'],
    estado: json['estado'] ?? true,
    categoria: json['categoria'] != null
        ? Categoria.fromJson(json['categoria'])
        : null,
  );
}