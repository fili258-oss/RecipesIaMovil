import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:users_auth/controllers/auth_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Español';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sección de perfil
          _buildSectionHeader('Perfil'),
          _buildProfileTile(),
          
          const SizedBox(height: 24),
          
          // Sección de preferencias
          _buildSectionHeader('Preferencias'),
          _buildNotificationsTile(),
          _buildDarkModeTile(),
          _buildLanguageTile(),
          
          const SizedBox(height: 24),
          
          // Sección de la aplicación
          _buildSectionHeader('Aplicación'),
          _buildAboutTile(),
          _buildHelpTile(),
          _buildPrivacyTile(),
          
          const SizedBox(height: 24),
          
          // Sección de cuenta
          _buildSectionHeader('Cuenta'),
          _buildLogoutTile(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildProfileTile() {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: const Text('Mi Perfil'),
        subtitle: const Text('Editar información personal'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showComingSoon('Editar perfil');
        },
      ),
    );
  }

  Widget _buildNotificationsTile() {
    return Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.notifications),
        title: const Text('Notificaciones'),
        subtitle: const Text('Recibir alertas y recordatorios'),
        value: _notificationsEnabled,
        onChanged: (bool value) {
          setState(() {
            _notificationsEnabled = value;
          });
        },
      ),
    );
  }

  Widget _buildDarkModeTile() {
    return Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.dark_mode),
        title: const Text('Modo Oscuro'),
        subtitle: const Text('Cambiar tema de la aplicación'),
        value: _darkModeEnabled,
        onChanged: (bool value) {
          setState(() {
            _darkModeEnabled = value;
          });
          _showComingSoon('Modo oscuro');
        },
      ),
    );
  }

  Widget _buildLanguageTile() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.language),
        title: const Text('Idioma'),
        subtitle: Text(_selectedLanguage),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showLanguageDialog();
        },
      ),
    );
  }

  Widget _buildAboutTile() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.info),
        title: const Text('Acerca de'),
        subtitle: const Text('Información de la aplicación'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showAboutDialog();
        },
      ),
    );
  }

  Widget _buildHelpTile() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.help),
        title: const Text('Ayuda y Soporte'),
        subtitle: const Text('Obtener ayuda'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showComingSoon('Ayuda y soporte');
        },
      ),
    );
  }

  Widget _buildPrivacyTile() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.privacy_tip),
        title: const Text('Privacidad'),
        subtitle: const Text('Política de privacidad'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showComingSoon('Política de privacidad');
        },
      ),
    );
  }

  Widget _buildLogoutTile() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Cerrar Sesión', 
          style: TextStyle(color: Colors.red)),
        onTap: () {
          _showLogoutDialog();
        },
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Idioma'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Español'),
                value: 'Español',
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Mis Recetas',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.restaurant_menu,
        color: Theme.of(context).primaryColor,
      ),
      children: [
        const Text('Una aplicación para guardar y organizar tus recetas favoritas.'),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature próximamente')),
    );
  }

  void _logout() {
    // Implementar lógica de cierre de sesión usando GetX
    Get.find<AuthController>().logout();
  }
}