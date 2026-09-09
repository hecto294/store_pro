class Categoria {
  final int id;
  final String nombre;
  final String descripcion;
  final bool estado;

  Categoria({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.estado,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
    id: json['id'],
    nombre: json['nombre'],
    descripcion: json['descripcion'] ?? '',
    estado: json['estado'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'descripcion': descripcion,
    'estado': estado,
  };
}