import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  Future<List<dynamic>> getList(String path) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}$path'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Erro ao consultar $path: ${response.body}');
  }

  Future<Map<String, dynamic>> getObject(String path) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}$path'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Erro ao consultar $path: ${response.body}');
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {};
    }

    throw Exception('Erro ao salvar em $path: ${response.body}');
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {};
    }

    throw Exception('Erro ao atualizar $path: ${response.body}');
  }

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {};
    }

    throw Exception('Erro ao alterar $path: ${response.body}');
  }

  Future<void> delete(String path) async {
    final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}$path'));

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception('Erro ao excluir $path: ${response.body}');
  }
}
