import 'package:appwrite/appwrite.dart';
import 'package:users_auth/core/constants/appwrite_constants.dart';
import 'package:users_auth/model/recipe_model.dart';

class RecipeRepository {
  final Databases databases;
  final resultRecipes = <RecipeModel>[];

  RecipeRepository(this.databases);

  Future<RecipeModel> createRecipe(RecipeModel recipe) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionId,
        documentId: ID.unique(),
        data: recipe.toJson(),
      );

      return RecipeModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RecipeModel>> getRecipes() async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionId,
      );
        
      final resultRecipes = <RecipeModel>[];
      for (var doc in response.documents) {
        try {
          final recipe = RecipeModel.fromJson(doc.data);
          resultRecipes.add(recipe);
        } catch (e, stack) {
          print('Error mapeando receta: $e');
          print(stack);
        }
      }

      if (resultRecipes.isNotEmpty) {
        print('Recetas obtenidas Data: ${resultRecipes.first}');
      } else {
        print('No se pudo mapear ninguna receta');
      }

      return resultRecipes;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      await databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionId,
        documentId: recipeId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<RecipeModel> updateRecipe(String recipeId, RecipeModel recipe) async {
    try {
      final response = await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionId,
        documentId: recipeId,
        data: recipe.toJson(),
      );

      return RecipeModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
