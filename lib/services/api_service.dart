
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/product_model.dart';

class ApiService {
  static const String _baseUrl = 'https://fakestoreapi.com';

  // --- AUTENTICACIÓN DE USUARIOS ---
  static Future<AuthResult> authenticateUser(String username, String password) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users')).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        List<dynamic> usersJson = jsonDecode(response.body);

        for (var userMap in usersJson) {
          String apiUser = userMap['username'] ?? '';
          String apiPass = userMap['password'] ?? '';

          bool passMatch = apiPass == password || apiPass.replaceAll('\$', '') == password;

          if (apiUser == username && passMatch) {
            return AuthResult(user: UserModel.fromJson(userMap));
          }
        }
        return AuthResult(errorMessage: 'Usuario o contraseña incorrectos.');
      } else {
        return AuthResult(errorMessage: 'Error en el servidor (${response.statusCode}).');
      }
    } on SocketException {
      return AuthResult(errorMessage: 'Sin conexión a internet.');
    } on TimeoutException {
      return AuthResult(errorMessage: 'Tiempo de espera agotado.');
    } catch (e) {
      return AuthResult(errorMessage: 'Ocurrió un error inesperado.');
    }
  }

  // --- US03: OBTENER TODOS LOS PRODUCTOS ---
  static Future<List<ProductModel>> getProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => ProductModel.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los productos');
    }
  }

  // --- US04: OBTENER CATEGORÍAS ---
  static Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/products/categories'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => item.toString()).toList();
    } else {
      throw Exception('Error al cargar las categorías');
    }
  }

  // --- US04: OBTENER PRODUCTOS POR CATEGORÍA ---
  static Future<List<ProductModel>> getProductsByCategory(String category) async {
    final response = await http.get(Uri.parse('$_baseUrl/products/category/$category'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => ProductModel.fromJson(item)).toList();
    } else {
      throw Exception('Error al filtrar por categoría');
    }
  }

  // --- US05: OBTENER PRODUCTO POR ID ---
  static Future<ProductModel?> getProductById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products/$id'));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return ProductModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}