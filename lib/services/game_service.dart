import 'dart:convert';
import 'package:battleships/services/auth_service.dart';
import 'package:http/http.dart' as http;

class GameService {
  final String baseUrl = 'https://battleships-app.onrender.com';

  Future<http.Response> getGames() async {
    final String? token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/games'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response;
  }

  Future<Map<String, dynamic>> createGame(List<String> ships,
      [String? ai]) async {
    final String? token = await AuthService().getToken();

    final body = json.encode({'ships': ships, if (ai != null) 'ai': ai});
    final response = await http.post(
      Uri.parse('$baseUrl/games'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create game');
    }
  }

  Future<http.Response> forfeitGame(int gameId) async {
    final String? token = await AuthService().getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/games/$gameId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response;
  }
}
