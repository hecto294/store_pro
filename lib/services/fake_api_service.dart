import 'dart:convert';
import '../models/producto.dart';

class FakeApiService {
  final String _jsonResponse = '''
  [
    {"id": "1", "nombre": "Teclado Mecanico RGB", "precio": 89.99, "categoria": "Accesorios"},
    {"id": "2", "nombre": "Audifonos Noise Cancelling", "precio": 120.00, "categoria": "Audio"},
    {"id": "3", "nombre": "Smartphone Pro X", "precio": 899.00, "categoria": "Moviles"},
    {"id": "4", "nombre": "Camara Mirrorless Z50", "precio": 1099.00, "categoria": "Fotografia"},
    {"id": "5", "nombre": "Silla Ergonomica ProSit", "precio": 320.00, "categoria": "Oficina"},
    {"id": "6", "nombre": "Parlante Bluetooth BoomBox", "precio": 79.90, "categoria": "Audio"},
    {"id": "7", "nombre": "Monitor Curvo 27 pulgadas", "precio": 389.00, "categoria": "Computadores"},
    {"id": "8", "nombre": "Mochila AntiRobo TravelSafe", "precio": 65.00, "categoria": "Accesorios de Viaje"}
  ]
  ''';

  Future<List<Producto>> obtenerProductos() async {
    await Future.delayed(const Duration(seconds: 2));
    final List<dynamic> listJson = jsonDecode(_jsonResponse);
    return listJson.map((item) => Producto.fromJson(item)).toList();
  }
}