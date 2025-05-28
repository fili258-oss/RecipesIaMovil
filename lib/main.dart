import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:users_auth/controllers/recipe_controller.dart';

import 'package:users_auth/core/config/app_config.dart';
import 'package:users_auth/data/repositories/auth_repository.dart';
import 'package:users_auth/controllers/auth_controller.dart';
import 'package:users_auth/controllers/user_controller.dart';
import 'package:users_auth/data/repositories/recipe_repository.dart';
import 'package:users_auth/data/repositories/user_repository.dart';
import 'package:users_auth/presentation/pages/capture/capture_recipe_screen.dart';
import 'package:users_auth/presentation/pages/settings/settings_screen.dart';
import 'package:users_auth/presentation/pages/splash_page.dart';
import 'package:users_auth/presentation/pages/recipes/add_recipe_screen.dart';
import 'package:users_auth/presentation/pages/recipes/edit_recipe_screen.dart';
import 'package:users_auth/presentation/pages/login_page.dart';
import 'package:users_auth/presentation/pages/recipes/recipes_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final client = AppwriteConfig.initClient();
  final databases = Databases(client);
  final account = Account(client);
  final storage = Storage(client);

  // Dependencies data base
  // Dependencies account
  Get.put(AuthRepository(account));
  
  Get.put(UserRepository(databases));
  Get.put(RecipeRepository(databases, storage));
  Get.put(UserController(repository: Get.find()));
  Get.put(RecipeController(repository: Get.find()));

  
  Get.put(AuthController(Get.find()));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Recetas IA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: false,
      ),
      home: SplashPage(),
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),        
        GetPage(name: '/recipes', page: () => RecipeListScreen()),        
        GetPage(name: '/add-recipes', page: () => AddRecipeScreen()),        
        GetPage(name: '/scan-recipe', page: () => CaptureRecipeScreen()),        
        GetPage(name: '/settings', page: () => SettingsScreen()),        
        GetPage(name: '/add-recipe', page: () => AddRecipeScreen()),        
        GetPage(
          name: '/edit-recipe/:id',
          page: () => EditRecipeScreen(),
        ),
      ],
    );
  }
}
