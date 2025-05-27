import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:users_auth/controllers/recipe_controller.dart';
import 'package:users_auth/controllers/auth_controller.dart';
import 'package:users_auth/model/recipe_model.dart';

class RecipeListScreen extends StatelessWidget {
  final RecipeController recipeController = Get.find<RecipeController>();

  RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis recetas'),
        automaticallyImplyLeading: false,
        actions: [          
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() => TextField(
              onChanged: recipeController.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Buscar receta...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: recipeController.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: recipeController.clearSearch,
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            )),
          ),
          // Lista de recetas filtradas
          Expanded(
            child: Obx(
              () => recipeController.filteredRecipes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: recipeController.filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipeController.filteredRecipes[index];
                        return RecipeCard(
                          recipe: recipe,
                          searchQuery: recipeController.searchQuery.value,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-recipe'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            recipeController.searchQuery.value.isEmpty
                ? 'No tienes recetas registradas'
                : 'No se encontraron recetas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final String? searchQuery;

  const RecipeCard({
    super.key, 
    required this.recipe,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: _buildHighlightedText(recipe.name, searchQuery),
        subtitle: Text('Ingredientes: ${recipe.id}'),
        trailing: Text(
          recipe.createdAt.toLocal().toIso8601String().split('T')[0],
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        onTap: () => Get.toNamed('/edit-recipe/${recipe.id}'),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String? query) {
    if (query == null || query.isEmpty) {
      return Text(text);
    }

    final matches = RegExp(query, caseSensitive: false).allMatches(text);
    if (matches.isEmpty) {
      return Text(text);
    }

    List<TextSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(text: TextSpan(children: spans, style: const TextStyle(color: Colors.black)));
  }
}
