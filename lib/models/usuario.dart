class Usuario {
  final String id;
  final String nombre;
  final String email;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
  });

  // Constructor factory: convierte un Map (que viene de decodificar JSON)
  // en un objeto Usuario real de Dart.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? 'Sin nombre',
      email: json['email'] ?? 'sin-correo@ejemplo.com',
    );
  }
}