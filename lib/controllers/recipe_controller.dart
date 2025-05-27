import 'package:get/get.dart';

import 'package:users_auth/model/recipe_model.dart';
import 'package:users_auth/data/repositories/recipe_repository.dart';

class RecipeController extends GetxController {
  final RecipeRepository repository;

  RecipeController({required this.repository});

  final RxList<RecipeModel> recipes = <RecipeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Nuevas propiedades para el buscador
  final RxString searchQuery = ''.obs;
  final RxList<RecipeModel> filteredRecipes = <RecipeModel>[].obs;

  @override
  void onInit() {
    super.onInit();    
    fetchRecipes();

    // Inicializar la lista filtrada
    filteredRecipes.assignAll(recipes);
    // Escuchar cambios en la consulta de búsqueda
    ever(searchQuery, (_) => filterRecipes());
    ever(recipes, (_) => filterRecipes());
  }

  void filterRecipes() {
    if (searchQuery.value.isEmpty) {
      filteredRecipes.assignAll(recipes);
    } else {
      filteredRecipes.assignAll(
        recipes.where((medication) =>
          medication.name.toLowerCase().contains(searchQuery.value.toLowerCase())
        ).toList()
      );
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  Future<void> fetchRecipes() async {
    try {
      isLoading.value = true;
      print('Cargando recetas...');
      final fetchedRecipes = await repository.getRecipes();
      print('Recetas obtenidas1: $fetchedRecipes');
      recipes.assignAll(fetchedRecipes);      
    } catch (e) {
      error.value = e.toString();
      recipes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addRecipe(RecipeModel recipe) async {
    try {
      final newRecipe = await repository.createRecipe(recipe);
      recipes.add(newRecipe);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      await repository.deleteRecipe(recipeId);
      recipes.removeWhere((user) => user.id == recipeId);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> updateRecipe(String recipeId, RecipeModel updatedRecipe) async {
    try {
      final recipe = await repository.updateRecipe(recipeId, updatedRecipe);
      final index = recipes.indexWhere((u) => u.id == recipeId);
      if (index != -1) {
        recipes[index] = recipe;
      }
    } catch (e) {
      error.value = e.toString();
    }
  }
}
