import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/producto.dart';
import 'auth_service.dart';

class ProductoService {
  final String baseUrl = Environment.apiUrl;
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Producto>> getProductos() async {
    final res = await http.get(Uri.parse('$baseUrl/productos'));
    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => Producto.fromJson(e)).toList();
    }
    throw Exception("Error al cargar productos");
  }

  Future<Producto> getProductoPorId(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/productos/$id'));
    if (res.statusCode == 200) return Producto.fromJson(jsonDecode(res.body));
    throw Exception("Producto no encontrado");
  }

  Future<bool> crearProducto(String nombre, double precio, int stock, int categoriaId) async {
    final headers = await _getHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/productos'),
      headers: headers,
      body: jsonEncode({'nombre': nombre, 'precio': precio, 'stock': stock, 'categoriaId': categoriaId}),
    );
    return res.statusCode == 201;
  }

  Future<bool> actualizarProducto(int id, String nombre, double precio, int stock, int categoriaId) async {
    final headers = await _getHeaders();
    final res = await http.put(
      Uri.parse('$baseUrl/productos/$id'),
      headers: headers,
      body: jsonEncode({'nombre': nombre, 'precio': precio, 'stock': stock, 'categoriaId': categoriaId}),
    );
    return res.statusCode == 200;
  }

  Future<bool> cambiarEstado(int id) async {
    final headers = await _getHeaders();
    final res = await http.patch(Uri.parse('$baseUrl/productos/$id/estado'), headers: headers);
    return res.statusCode == 200;
  }
}