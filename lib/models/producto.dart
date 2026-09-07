import 'package:flutter/foundation.dart';

class Producto {
  final String id;
  final String nombre;
  final double precio;
  final String categoria;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
  });

  // FACTORY CONSTRUCTOR PARA CONVERTIR MAP (JSON) A OBJETO DART
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? 'Sin nombre',
      precio: (json['precio'] as num).toDouble(),
      categoria: json['categoria'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
    };
  }
}