import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/categoria.dart';
import 'auth_service.dart';

class CategoriaService {
  final String baseUrl = Environment.apiUrl;
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Categoria>> getCategorias() async {
    final res = await http.get(Uri.parse('$baseUrl/categorias'));
    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => Categoria.fromJson(e)).toList();
    }
    throw Exception("Error al cargar categorías");
  }

  Future<Categoria> getCategoriaPorId(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/categorias/$id'));
    if (res.statusCode == 200) return Categoria.fromJson(jsonDecode(res.body));
    throw Exception("Categoría no encontrada");
  }

  Future<bool> crearCategoria(String nombre, String descripcion) async {
    final headers = await _getHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/categorias'),
      headers: headers,
      body: jsonEncode({'nombre': nombre, 'descripcion': descripcion}),
    );
    return res.statusCode == 201;
  }

  Future<bool> actualizarCategoria(int id, String nombre, String descripcion) async {
    final headers = await _getHeaders();
    final res = await http.put(
      Uri.parse('$baseUrl/categorias/$id'),
      headers: headers,
      body: jsonEncode({'nombre': nombre, 'descripcion': descripcion}),
    );
    return res.statusCode == 200;
  }

  Future<bool> cambiarEstado(int id) async {
    final headers = await _getHeaders();
    final res = await http.patch(Uri.parse('$baseUrl/categorias/$id/estado'), headers: headers);
    return res.statusCode == 200;
  }
}