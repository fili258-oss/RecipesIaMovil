import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:users_auth/model/recipe_model.dart';
import 'package:users_auth/data/repositories/recipe_repository.dart';
import 'package:users_auth/data/repositories/auth_repository.dart';

class RecipeController extends GetxController {
  final RecipeRepository repository;
  final AuthRepository authRepository = Get.find<AuthRepository>();
  final ImagePicker _picker = ImagePicker();

  RecipeController({required this.repository});

  // ========== PROPIEDADES EXISTENTES ==========
  final RxList<RecipeModel> recipes = <RecipeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Propiedades para el buscador
  final RxString searchQuery = ''.obs;
  final RxList<RecipeModel> filteredRecipes = <RecipeModel>[].obs;
  // ========== NUEVAS PROPIEDADES PARA IA ==========
  
  // Estados de captura y análisis
  final RxBool isAnalyzing = false.obs;
  final RxBool isCapturing = false.obs;
  final RxBool isSaving = false.obs;
  
  // Imagen seleccionada y análisis
  final Rx<File?> selectedImage = Rx<File?>(null);
  final Rx<RecipeAnalysisResponse?> analysisResult = Rx<RecipeAnalysisResponse?>(null);
  
  // Estados computados
  bool get hasImage => selectedImage.value != null;
  bool get hasAnalysis => analysisResult.value != null;
  bool get canSaveRecipe => analysisResult.value?.isRecipe == true;
  bool get isProcessing => isAnalyzing.value || isCapturing.value || isSaving.value;

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

  // ========== MÉTODOS EXISTENTES ==========
  
  void filterRecipes() {
    if (searchQuery.value.isEmpty) {
      filteredRecipes.assignAll(recipes);
    } else {
      filteredRecipes.assignAll(
        recipes.where((recipe) =>
          recipe.name.toLowerCase().contains(searchQuery.value.toLowerCase())
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
      error.value = '';
      print('🔄 Cargando recetas...');
              
              
      final fetchedRecipes = await repository.getRecipes();
      print('✅ Recetas obtenidas: ${fetchedRecipes.length}');
      
      recipes.assignAll(fetchedRecipes);      
    } catch (e) {
      print('❌ Error cargando recetas: $e');
      error.value = e.toString();
      recipes.clear();
      
      // Mostrar snackbar de error
      Get.snackbar(
        'Error',
        'Error al cargar recetas: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addRecipe(RecipeModel recipe) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final newRecipe = await repository.createRecipe(recipe);
      recipes.add(newRecipe);
      
      Get.snackbar(
        'Éxito',
        'Receta agregada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      print('❌ Error agregando receta: $e');
      error.value = e.toString();
      
      Get.snackbar(
        'Error',
        'Error al agregar receta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await repository.deleteRecipe(recipeId);
      recipes.removeWhere((recipe) => recipe.id == recipeId);
      
      Get.snackbar(
        'Éxito',
        'Receta eliminada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      print('❌ Error eliminando receta: $e');
      error.value = e.toString();
      
      Get.snackbar(
        'Error',
        'Error al eliminar receta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRecipe(String recipeId, RecipeModel updatedRecipe) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final recipe = await repository.updateRecipe(recipeId, updatedRecipe);
      final index = recipes.indexWhere((r) => r.id == recipeId);
      if (index != -1) {
        recipes[index] = recipe;
      }
      
      Get.snackbar(
        'Éxito',
        'Receta actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      print('❌ Error actualizando receta: $e');
      error.value = e.toString();
      
      Get.snackbar(
        'Error',
        'Error al actualizar receta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== NUEVOS MÉTODOS PARA IA ==========

  /// Capturar imagen desde cámara
  Future<void> captureFromCamera() async {
    await _getImage(ImageSource.camera);
  }

  /// Seleccionar imagen desde galería
  Future<void> selectFromGallery() async {
    await _getImage(ImageSource.gallery);
  }

  /// Método privado para obtener imagen
  Future<void> _getImage(ImageSource source) async {
    try {
      isCapturing.value = true;
      error.value = '';

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        analysisResult.value = null; // Limpiar análisis anterior
        
        print('📸 Imagen seleccionada: ${pickedFile.path}');
        
        Get.snackbar(
          'Imagen Seleccionada',
          'Imagen cargada correctamente. Ahora puedes analizarla.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }
    } catch (e) {
      print('❌ Error seleccionando imagen: $e');
      error.value = 'Error al seleccionar imagen: ${e.toString()}';
      
      Get.snackbar(
        'Error',
        'Error al seleccionar imagen: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isCapturing.value = false;
    }
  }

  /// Analizar imagen con IA
  Future<void> analyzeImageWithAI() async {
    if (selectedImage.value == null) {
      error.value = 'No hay imagen seleccionada';
      Get.snackbar(
        'Error',
        'Primero selecciona una imagen',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    try {
      isAnalyzing.value = true;
      error.value = '';

      print('🤖 Iniciando análisis con IA...');

      final result = await repository.analyzeImageWithAI(selectedImage.value!);
      analysisResult.value = result;

      if (result.isRecipe) {
        print('✅ Receta detectada: ${result.recipeName}');
        Get.snackbar(
          '¡Receta Detectada!',
          result.recipeName ?? 'Receta identificada correctamente',
          snackPosition: SnackPosition.BOTTOM,          
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 3),
        );
      } else {
        print('⚠️ No es una receta válida');
        Get.snackbar(
          'No es una receta',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.secondary,
          colorText: Get.theme.colorScheme.onSecondary,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('❌ Error en análisis: $e');
      error.value = 'Error al analizar imagen: ${e.toString()}';
      
      Get.snackbar(
        'Error de Análisis',
        'Error al analizar la imagen: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isAnalyzing.value = false;
    }
  }

  /// Guardar receta desde análisis de IA
  Future<bool> saveRecipeFromAI({String? userId}) async {
    if (analysisResult.value == null || 
        !analysisResult.value!.isRecipe || 
        selectedImage.value == null) {
      error.value = 'No hay datos válidos para guardar';
      Get.snackbar(
        'Error',
        'No hay una receta válida para guardar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }

    try {
      isSaving.value = true;
      error.value = '';

      // Usar el ID de usuario proporcionado o uno temporal
      final currentUserId = userId ?? 'user_temp_id';

      print('💾 Guardando receta desde IA...');

      // Mostrar progreso al usuario
      Get.snackbar(
        'Guardando...',
        'Subiendo imagen y guardando receta',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        showProgressIndicator: true,
        isDismissible: false,
        duration: const Duration(seconds: 10), // Más tiempo para el upload
      );
      
      // Usar el método integrado del repository
      final createdRecipe = await repository.createRecipeFromAI(
        analysisResult: analysisResult.value!,
        userId: currentUserId,
        imageFile: selectedImage.value!,
      );
      
      // ignore: unnecessary_null_comparison
      if (createdRecipe != null || createdRecipe != "") {
        // Agregar la nueva receta a la lista
        recipes.add(createdRecipe);
        
        print('✅ Receta guardada exitosamente: ${createdRecipe.name}');
        print('🖼️ URL de imagen: ${createdRecipe.imagePath}');

        // Cerrar snackbar de progreso
        Get.closeAllSnackbars();

        Get.snackbar(
          '¡Éxito!',
          'Receta "${createdRecipe.name}" guardada correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 3),
        );

        // Limpiar datos después de guardar
        clearCaptureData();
        
        return true;
      } else {
        throw Exception('No se pudo obtener el contenido de la receta creada');
      }
    } catch (e) {
      print('❌ Error guardando receta: $e');
      error.value = 'Error al guardar receta: ${e.toString()}';
      
      Get.snackbar(
        'Error al Guardar',
        'Error al guardar la receta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Limpiar datos de captura
  void clearCaptureData() {
    selectedImage.value = null;
    analysisResult.value = null;
    error.value = '';
    print('🧹 Datos de captura limpiados');
  }

  /// Resetear completamente el estado de captura
  void resetCaptureState() {
    clearCaptureData();
    isAnalyzing.value = false;
    isCapturing.value = false;
    isSaving.value = false;
    print('🔄 Estado de captura reseteado');
  }

  // ========== MÉTODOS DE UTILIDAD ==========

  /// Obtener información de la receta analizada
  Map<String, dynamic>? getRecipeInfo() {
    if (analysisResult.value == null || !analysisResult.value!.isRecipe) {
      return null;
    }

    return {
      'name': analysisResult.value!.recipeName,
      'ingredients': analysisResult.value!.ingredients,
      'description': analysisResult.value!.description,
      'isValid': analysisResult.value!.recipeName?.isNotEmpty == true,
    };
  }

  /// Obtener lista de ingredientes como String
  String getIngredientsAsString() {
    final ingredients = analysisResult.value?.ingredients;
    if (ingredients == null || ingredients.isEmpty) {
      return '';
    }
    return ingredients.join(', ');
  }

  /// Obtener resumen de la receta
  String getRecipeSummary() {
    if (analysisResult.value == null || !analysisResult.value!.isRecipe) {
      return 'No hay receta analizada';
    }

    final name = analysisResult.value!.recipeName ?? 'Sin nombre';
    final ingredientsCount = analysisResult.value!.ingredients?.length ?? 0;
    
    return '$name - $ingredientsCount ingredientes detectados';
  }

  /// Validar si se puede analizar la imagen
  bool canAnalyzeImage() {
    return selectedImage.value != null && 
           selectedImage.value!.existsSync() &&
           !isAnalyzing.value;
  }

  /// Obtener mensaje de estado actual
  String getStateMessage() {
    if (isCapturing.value) return 'Cargando imagen...';
    if (isAnalyzing.value) return 'Analizando imagen con IA...';
    if (isSaving.value) return 'Guardando receta...';
    if (hasAnalysis && analysisResult.value!.isRecipe) return 'Receta detectada correctamente';
    if (hasAnalysis && !analysisResult.value!.isRecipe) return 'Imagen analizada - No es una receta';
    if (hasImage) return 'Imagen seleccionada - Lista para analizar';
    return 'Selecciona una imagen para comenzar';
  }

  // ========== BÚSQUEDAS ADICIONALES ==========

  /// Buscar recetas por usuario
  Future<void> fetchRecipesByUser(String userId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final userRecipes = await repository.getRecipesByUser(userId);
      recipes.assignAll(userRecipes);
      
      print('✅ Recetas del usuario $userId: ${userRecipes.length}');
    } catch (e) {
      print('❌ Error obteniendo recetas del usuario: $e');
      error.value = e.toString();
      recipes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Buscar recetas por nombre del usuario actual
  Future<void> searchRecipesByName(String searchTerm) async {
    try {
      isLoading.value = true;
      error.value = '';

      
      final searchResults = await repository.searchRecipesByName(
        searchTerm
        
      );
      recipes.assignAll(searchResults);
            
    } catch (e) {
      print('❌ Error en búsqueda: $e');
      error.value = e.toString();
      recipes.clear();
    } finally {
      isLoading.value = false;
    }
  }


  /// Obtener ID del usuario actual
  /*String getCurrentUserId() {
    return currentUserId.value;
  }*/

  /// Verificar si hay un usuario autenticadoR
  //bool get isUserAuthenticated => currentUserId.value.isNotEmpty;

  @override
  void onClose() {
    // Limpiar recursos al cerrar el controlador
    clearCaptureData();
    super.onClose();
  }
}