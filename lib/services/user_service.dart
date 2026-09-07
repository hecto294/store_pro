import 'dart:convert';
import '../models/usuario.dart';

class UserService {
  final String _jsonResponse = '''
  [
    {"id": "1", "nombre": "Laura Gomez", "email": "laura.gomez@correo.com"},
    {"id": "2", "nombre": "Carlos Ramirez", "email": "carlos.ramirez@correo.com"},
    {"id": "3", "nombre": "Ana Martinez", "email": "ana.martinez@correo.com"},
    {"id": "4", "nombre": "Jorge Salazar", "email": "jorge.salazar@correo.com"},
    {"id": "5", "nombre": "Paula Herrera", "email": "paula.herrera@correo.com"}
  ]
  ''';

  // Método asíncrono que simula el retardo de una petición de red real.
  Future<List<Usuario>> fetchUsuarios() async {
    await Future.delayed(const Duration(seconds: 2));

    final List<dynamic> listJson = jsonDecode(_jsonResponse);
    return listJson.map((item) => Usuario.fromJson(item)).toList();
  }
}