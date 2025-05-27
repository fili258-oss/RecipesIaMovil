import 'package:flutter/material.dart';
import 'package:users_auth/presentation/pages/recipes/recipes_list_screen.dart';
import 'package:users_auth/presentation/pages/capture/capture_recipe_screen.dart';
import 'package:users_auth/presentation/pages/settings/settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  // Lista de las pantallas que se mostrarán
  final List<Widget> _screens = [
    RecipeListScreen(),
    CaptureRecipeScreen(),
    SettingsScreen(),

  ];


  int currentIndex = 0;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
            currentIndex = index;
          });                    
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(            
            icon: const Icon(Icons.restaurant_menu),
            activeIcon: const Icon(Icons.restaurant_menu),
            label: 'Mis Recetas',
            
          ),
          BottomNavigationBarItem(            
            icon: const Icon(Icons.camera_alt_outlined),
            activeIcon: const Icon(Icons.camera_alt),
            label: 'Capturar',
          ),
          BottomNavigationBarItem(            
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}