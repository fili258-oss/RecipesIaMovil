import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:users_auth/core/constants/appwrite_constants.dart';
import 'package:users_auth/model/recipe_model.dart';
import 'package:path/path.dart' as path;


class RecipeRepository {
  final Databases databases;
  final Storage storage;
  final resultRecipes = <RecipeModel>[];

  RecipeRepository(this.databases, this.storage);

  // ========== MÉTODOS CRUD EXISTENTES ==========
  
  Future<RecipeModel> createRecipe(RecipeModel recipe) async {
    try {
      print(recipe.toJson());
      final response = await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionId,
        documentId: ID.unique(),
        data: recipe.toJson(),
      );

      return RecipeModel.fromJson(response.data);
    } catch (e) {
      print('❌ Error creando receta: $e');
      rethrow;
    }
  }

  Future<List<RecipeModel>> getRecipes() async {
    try {
      final response = await databases.listDocuments(        
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionId,
        queries: [
          Query.equal('active', true),
          Query.orderDesc('created_at'),
        ],
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
        print('✅ Recetas obtenidas: ${resultRecipes.length}');        
      } else {
        print('⚠️ No se encontraron recetas');
      }

      return resultRecipes;
    } catch (e) {
      print('❌ Error obteniendo recetas: $e');
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
      print('✅ Receta eliminada: $recipeId');
    } catch (e) {
      print('❌ Error eliminando receta: $e');
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

      print('✅ Receta actualizada: $recipeId');
      return RecipeModel.fromJson(response.data);
    } catch (e) {
      print('❌ Error actualizando receta: $e');
      rethrow;
    }
  }

  // ========== NUEVOS MÉTODOS PARA IA Y BÚSQUEDAS ==========

  /// Analiza una imagen con Gemini AI para detectar recetas
  Future<RecipeAnalysisResponse> analyzeImageWithAI(File imageFile) async {
    try {
      // Validar que el archivo existe
      if (!await imageFile.exists()) {
        throw Exception('El archivo de imagen no existe');
      }

      // Obtener la API key desde el archivo .env
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key de Gemini no encontrada. Revisa tu archivo .env');
      }

      print('🤖 Iniciando análisis con Gemini AI...');

      // Crear instancia del modelo de Gemini
      final model = GenerativeModel(
        model: 'gemini-2.0-flash-lite',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.4,
          topK: 32,
          topP: 1,
          maxOutputTokens: 2048,
        ),
      );

      // Leer la imagen como bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();
      print('📸 Imagen cargada: ${imageBytes.length} bytes');

      // Prompt optimizado para análisis de recetas
      const prompt = '''
Analiza esta imagen cuidadosamente y determina si contiene una receta, plato de comida, ingredientes culinarios o algo relacionado con cocina.

INSTRUCCIONES IMPORTANTES:
1. Si es una receta, plato de comida o ingredientes culinarios, responde con isRecipe: true
2. Si NO es comida (ej: personas, paisajes, objetos no culinarios), responde con isRecipe: false
3. Sé específico y preciso en la identificación de ingredientes
4. El nombre debe ser descriptivo y apetitoso
5. Incluye máximo 8 ingredientes principales
6. La descripción debe ser breve (máximo 2 líneas)

FORMATO DE RESPUESTA (JSON únicamente):

Para COMIDA/RECETA:
{
  "isRecipe": true,
  "recipeName": "Nombre específico del plato (ej: Pasta Carbonara, Ensalada César)",
  "ingredients": ["ingrediente1", "ingrediente2", "ingrediente3"],
  "message": "Receta detectada correctamente",
  "description": "Descripción breve y apetitosa del plato"
}

Para NO COMIDA:
{
  "isRecipe": false,
  "message": "Lo siento, solo acepto fotografías de platos de comida, recetas o ingredientes culinarios. Por favor, sube una imagen relacionada con cocina."
}

RESPONDE ÚNICAMENTE CON EL JSON, SIN TEXTO ADICIONAL.
''';

      // Realizar la consulta a Gemini
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      final responseText = response.text?.trim() ?? '';

      if (responseText.isEmpty) {
        throw Exception('Respuesta vacía de Gemini AI');
      }

      print('🔍 Respuesta de Gemini: ${responseText.substring(0, responseText.length.clamp(0, 200))}...');

      // Limpiar y parsear la respuesta JSON
      final cleanJson = _cleanJsonResponse(responseText);
      final Map<String, dynamic> jsonResponse = jsonDecode(cleanJson);
      
      final analysisResult = RecipeAnalysisResponse.fromJson(jsonResponse);
      
      if (analysisResult.isRecipe) {
        print('✅ Receta detectada: ${analysisResult.recipeName}');
        print('🥘 Ingredientes: ${analysisResult.ingredients?.length ?? 0}');
      } else {
        print('⚠️ No es una receta válida');
      }

      return analysisResult;

    } catch (e) {
      // Log del error para debugging
      print('❌ Error en análisis de IA: $e');
      
      // Retornar respuesta de error
      return RecipeAnalysisResponse(
        isRecipe: false,
        message: 'Error al analizar la imagen: ${e.toString()}',
      );
    }
  }

    /// Subir imagen a AppWrite Storage y obtener URL pública
  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      print('📤 Subiendo imagen a AppWrite Storage...');
      
      // Validar tamaño del archivo
      final fileSize = await imageFile.length();
      if (fileSize > AppwriteConstants.maxImageSize) {
        throw Exception('La imagen es muy grande. Máximo ${AppwriteConstants.maxImageSize / (1024 * 1024)}MB');
      }

      // Validar tipo de archivo
      final fileExtension = path.extension(imageFile.path).toLowerCase().replaceAll('.', '');
      if (!AppwriteConstants.allowedImageTypes.contains(fileExtension)) {
        throw Exception('Tipo de archivo no permitido. Usa: ${AppwriteConstants.allowedImageTypes.join(', ')}');
      }

      // Generar nombre único para el archivo
      final fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}.$fileExtension';
      
      print('📁 Nombre del archivo: $fileName');
      print('📏 Tamaño: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      // Subir archivo a AppWrite Storage
      final file = await storage.createFile(
        bucketId: AppwriteConstants.storageId,
        fileId: ID.unique(),
        file: InputFile.fromPath(
          path: imageFile.path,
          filename: fileName,
        ),
      );

      print('✅ Imagen subida exitosamente. File ID: ${file.$id}');

      // Generar URL pública
      final publicUrl = AppwriteConstants.getImageUrl(file.$id);
      print('🔗 URL pública generada: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('❌ Error subiendo imagen: $e');
      throw Exception('Error al subir imagen: $e');
    }
  }

  /// Crear receta desde análisis de IA
  Future<RecipeModel> createRecipeFromAI({
    required RecipeAnalysisResponse analysisResult,
    required String userId,
    required File imageFile,
  }) async {
    try {
      if (!analysisResult.isRecipe) {
        throw Exception('El análisis no corresponde a una receta válida');
      }

      print('🍳 Creando receta desde IA: ${analysisResult.recipeName}');
      print('📤 Paso 1: Subiendo imagen...');

      // Subir imagen primero y obtener URL pública
      final imageUrl = await uploadImageToStorage(imageFile);      
      print('📄 Paso 2: Creando receta...');

      // Convertir análisis a RecipeModel
      final recipe = analysisResult.toRecipeModel(
        userId: userId,
        imagePath: imageUrl

      );

      print('💾 Paso 3: Guardando en base de datos...');

      // Usar el método existente para crear la receta
      final createdRecipe = await createRecipe(recipe);
      
      print('✅ Receta creada exitosamente con ID: ${createdRecipe.id}');
      print('🖼️ URL de imagen: ${createdRecipe.imagePath}');
      
      return createdRecipe;
    } catch (e) {
      print('❌ Error creando receta desde IA: $e');
      rethrow;
    }
  }

  /// Obtener recetas por usuario
  Future<List<RecipeModel>> getRecipesByUser(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('active', true),
          Query.orderDesc('created_at'),
        ],
      );

      final userRecipes = <RecipeModel>[];
      for (var doc in response.documents) {
        try {
          final recipe = RecipeModel.fromJson(doc.data);
          userRecipes.add(recipe);
        } catch (e) {
          print('Error mapeando receta de usuario: $e');
        }
      }

      print('✅ Recetas del usuario $userId: ${userRecipes.length}');
      return userRecipes;
    } catch (e) {
      print('❌ Error obteniendo recetas del usuario: $e');
      rethrow;
    }
  }

  /// Buscar recetas por nombre
  Future<List<RecipeModel>> searchRecipesByName(String searchTerm) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionId,
        queries: [
          Query.search('name', searchTerm),
          Query.equal('active', true),
          Query.orderDesc('created_at')
        ],
      );

      final searchResults = <RecipeModel>[];
      for (var doc in response.documents) {
        try {
          final recipe = RecipeModel.fromJson(doc.data);
          searchResults.add(recipe);
        } catch (e) {
          print('Error mapeando resultado de búsqueda: $e');
        }
      }

      print('🔍 Resultados de búsqueda para "$searchTerm": ${searchResults.length}');
      return searchResults;
    } catch (e) {
      print('❌ Error en búsqueda: $e');
      rethrow;
    }
  }

  /// Cambiar estado activo de una receta (soft delete)
  Future<RecipeModel> toggleRecipeActive(String recipeId, bool active) async {
    try {
      final response = await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionId,
        documentId: recipeId,
        data: {'active': active},
      );

      print('✅ Estado de receta cambiado: $recipeId -> $active');
      return RecipeModel.fromJson(response.data);
    } catch (e) {
      print('❌ Error cambiando estado de receta: $e');
      rethrow;
    }
  }

  // ========== MÉTODOS PRIVADOS ==========

  String _cleanJsonResponse(String responseText) {
    String cleanJson = responseText.trim();
    
    // Remover markdown si existe
    if (cleanJson.contains('```json')) {
      final startIndex = cleanJson.indexOf('```json') + 7;
      final endIndex = cleanJson.lastIndexOf('```');
      if (endIndex > startIndex) {
        cleanJson = cleanJson.substring(startIndex, endIndex).trim();
      }
    } else if (cleanJson.contains('```')) {
      final parts = cleanJson.split('```');
      if (parts.length >= 2) {
        cleanJson = parts[1].trim();
      }
    }
    
    // Validar que empiece y termine con llaves
    if (!cleanJson.startsWith('{')) {
      final startIndex = cleanJson.indexOf('{');
      if (startIndex != -1) {
        cleanJson = cleanJson.substring(startIndex);
      }
    }
    
    if (!cleanJson.endsWith('}')) {
      final endIndex = cleanJson.lastIndexOf('}');
      if (endIndex != -1) {
        cleanJson = cleanJson.substring(0, endIndex + 1);
      }
    }
    
    return cleanJson;
  }
}