class Usuario {
  final int? id;
  final String email;
  final String nombre;
  final String role;

  Usuario({
    this.id,
    required this.email,
    required this.nombre,
    required this.role,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      role: json['role'] ?? 'vendedor',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nombre': nombre,
    'role': role,
  };
}