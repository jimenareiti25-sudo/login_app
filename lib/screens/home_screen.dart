
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userRole;

  const HomeScreen({Key? key, required this.userRole}) : super(key: key);

  void _handleLogout(BuildContext context) async {
    final AuthService authService = AuthService();
    await authService.logout();

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Map<String, dynamic> _getRoleConfig() {
    switch (userRole) {
      case 'Administrador':
        return {
          'color': const Color(0xFF4834D4),
          'icon': Icons.admin_panel_settings_rounded,
          'title': 'PANEL DE ADMINISTRADOR',
          'description': 'Gestión global de la plataforma y permisos de usuario.',
          'modules': [
            {'name': 'Gestionar Usuarios', 'icon': Icons.people},
            {'name': 'Configurar Roles', 'icon': Icons.security},
            {'name': 'Registros de Red', 'icon': Icons.dns},
            {'name': 'Base de Datos', 'icon': Icons.storage},
          ],
        };
      case 'Auditor':
        return {
          'color': Colors.deepOrange,
          'icon': Icons.fact_check_rounded,
          'title': 'PANEL DE AUDITORÍA',
          'description': 'Monitoreo de eventos, logs y revisiones de seguridad.',
          'modules': [
            {'name': 'Logs de Sistema', 'icon': Icons.receipt_long},
            {'name': 'Historial Accesos', 'icon': Icons.history},
            {'name': 'Alertas', 'icon': Icons.warning_amber_rounded},
            {'name': 'Informes', 'icon': Icons.assessment},
          ],
        };
      default:
        return {
          'color': Colors.teal,
          'icon': Icons.shopping_bag_rounded,
          'title': 'PANEL DE CLIENTE',
          'description': 'Catálogo de productos e historial de compras.',
          'modules': [
            {'name': 'Catálogo', 'icon': Icons.storefront},
            {'name': 'Mis Pedidos', 'icon': Icons.local_shipping},
            {'name': 'Favoritos', 'icon': Icons.favorite_border},
            {'name': 'Soporte', 'icon': Icons.headset_mic},
          ],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getRoleConfig();
    final Color primaryColor = config['color'];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text(config['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.power_settings_new),
              tooltip: 'Cerrar Sesión',
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 6,
                shadowColor: primaryColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Icon(config['icon'], size: 36, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Rol Activo:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(
                              userRole,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              config['description'],
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Módulos del $userRole',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: (config['modules'] as List).length,
                itemBuilder: (context, index) {
                  final module = config['modules'][index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(module['icon'], size: 36, color: primaryColor),
                          const SizedBox(height: 8),
                          Text(
                            module['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}