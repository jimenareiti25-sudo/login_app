
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Base de datos local simulada basada en los usuarios reales de Fake Store API
  final Map<String, Map<String, dynamic>> _users = {
    'johnd': {'pass': 'm38rmF\$', 'id': 1},
    'mor_2314': {'pass': '83r5^_', 'id': 2},
    'kevinryan': {'pass': 'kevinfan2083', 'id': 3},
    'donte': {'pass': 'ewfr_v', 'id': 4},
  };

  Future<Map<String, dynamic>> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (_users.containsKey(username)) {
      String correctPass = _users[username]!['pass'];
      // Permite la contraseña con o sin escape del signo $
      if (password == correctPass || password == correctPass.replaceAll('\$', '')) {
        int userId = _users[username]!['id'];
        String role = assignRole(userId);
        String token = 'token_auth_user_$userId';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', role);
        await prefs.setInt('user_id', userId);

        return {'success': true, 'role': role, 'userId': userId};
      }
    }
    return {'success': false, 'message': 'Usuario o contraseña inválidos'};
  }

  // Regla de Negocio US01: ID 1/2 -> Administrador | ID 3 -> Auditor | Restantes -> Cliente
  String assignRole(int userId) {
    if (userId == 1 || userId == 2) {
      return 'Administrador';
    } else if (userId == 3) {
      return 'Auditor';
    } else {
      return 'Cliente';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_id');
  }
}