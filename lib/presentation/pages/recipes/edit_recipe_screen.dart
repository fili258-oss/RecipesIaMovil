import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:users_auth/controllers/recipe_controller.dart';
import 'package:users_auth/model/recipe_model.dart';

class EditRecipeScreen extends StatefulWidget {
  const EditRecipeScreen({super.key});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Controladores de texto
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ingredientController = TextEditingController();
  
  // Variables reactivas
  final RxList<String> ingredients = <String>[].obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxString currentImageUrl = ''.obs;
  final RxBool imageChanged = false.obs;

  // Datos de la receta
  late String recipeId;
  late RecipeModel currentRecipe;
  
  // Obtener el controlador de recetas
  RecipeController get recipeController => Get.find<RecipeController>();

  @override
  void initState() {
    super.initState();
    _initializeRecipeData();
  }

  void _initializeRecipeData() {
    // Obtener el ID de la receta desde los parámetros
    recipeId = Get.parameters['id'] ?? Get.arguments?['id'] ?? '';
    
    if (recipeId.isEmpty) {
      Get.back();
      Get.snackbar(
        'Error',
        'ID de receta no válido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Buscar la receta en la lista
    try {
      currentRecipe = recipeController.recipes.firstWhere(
        (recipe) => recipe.id == recipeId,
      );
      
      // Cargar datos en los controladores
      _loadRecipeData();
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Receta no encontrada',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _loadRecipeData() {
    // Cargar nombre
    nameController.text = currentRecipe.name;
    
    // Cargar ingredientes y descripción desde JSON
    try {
      final ingredientsData = jsonDecode(currentRecipe.ingredients);
      
      if (ingredientsData is Map<String, dynamic>) {
        // Cargar ingredientes
        if (ingredientsData.containsKey('ingredients') && 
            ingredientsData['ingredients'] is List) {
          ingredients.value = List<String>.from(ingredientsData['ingredients']);
        }
        
        // Cargar descripción
        if (ingredientsData.containsKey('description')) {
          descriptionController.text = ingredientsData['description'] ?? '';
        }
      } else if (ingredientsData is List) {
        // Formato antiguo - solo lista de ingredientes
        ingredients.value = List<String>.from(ingredientsData);
      }
    } catch (e) {
      print('Error parsing ingredients: $e');
      // Si no se puede parsear, intentar como string simple
      if (currentRecipe.ingredients.isNotEmpty) {
        ingredients.value = currentRecipe.ingredients
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
    
    // Cargar URL de imagen actual
    currentImageUrl.value = currentRecipe.imagePath;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    ingredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Receta'),        
        actions: [
          // Botón eliminar
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context),
            tooltip: 'Eliminar receta',
          ),
          // Indicador de carga
          Obx(() => isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de imagen
              _buildImageSection(),
              const SizedBox(height: 24),
              
              // Nombre de la receta
              _buildNameField(),
              const SizedBox(height: 20),
              
              // Descripción
              _buildDescriptionField(),
              const SizedBox(height: 20),
              
              // Ingredientes
              _buildIngredientsSection(),
              const SizedBox(height: 24),
              
              // Botones de acción
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Sección de imagen
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen de la Receta',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Obx(() {
          // Mostrar imagen nueva seleccionada
          if (selectedImage.value != null) {
            return _buildNewImagePreview();
          }
          // Mostrar imagen actual de la receta
          else if (currentImageUrl.value.isNotEmpty) {
            return _buildCurrentImagePreview();
          }
          // Mostrar placeholder para agregar imagen
          else {
            return _buildImagePlaceholder();
          }
        }),
      ],
    );
  }

  Widget _buildNewImagePreview() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  selectedImage.value!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NUEVA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: isUploadingImage.value 
                  ? null 
                  : () {
                      selectedImage.value = null;
                      imageChanged.value = false;
                    },
              icon: const Icon(Icons.undo, color: Colors.orange),
              label: const Text('Deshacer', style: TextStyle(color: Colors.orange)),
            ),
            TextButton.icon(
              onPressed: isUploadingImage.value ? null : _showImagePicker,
              icon: const Icon(Icons.edit),
              label: const Text('Cambiar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentImagePreview() {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              currentImageUrl.value,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: isUploadingImage.value 
                  ? null 
                  : () {
                      currentImageUrl.value = '';
                      imageChanged.value = true;
                    },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
            TextButton.icon(
              onPressed: isUploadingImage.value ? null : _showImagePicker,
              icon: const Icon(Icons.edit),
              label: const Text('Cambiar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return InkWell(
      onTap: _showImagePicker,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade400,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              'Agregar imagen de la receta',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Toca para seleccionar',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Campo de nombre
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre de la Receta',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Ej: Conejo asado con papas',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.restaurant),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre de la receta es requerido';
            }
            if (value.trim().length < 3) {
              return 'El nombre debe tener al menos 3 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Campo de descripción
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Describe tu receta, sabores, técnica de cocción...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value != null && value.trim().isNotEmpty && value.trim().length < 10) {
              return 'La descripción debe tener al menos 10 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Sección de ingredientes
  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredientes',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Campo para agregar ingrediente
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: ingredientController,
                decoration: const InputDecoration(
                  hintText: 'Agregar ingrediente',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.add),
                ),
                onFieldSubmitted: (_) => _addIngredient(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addIngredient,
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Lista de ingredientes
        Obx(() {
          if (ingredients.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: Center(
                child: Text(
                  'No hay ingredientes agregados',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            );
          }
          
          return Column(
            children: [
              Text(
                '${ingredients.length} ingrediente(s):',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: ingredients.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ingredient = entry.value;
                  
                  return Chip(
                    label: Text(ingredient),
                    backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeIngredient(index),
                    labelStyle: TextStyle(
                      color: Get.theme.primaryColor,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }),
        
        const SizedBox(height: 8),
        
        // Validación de ingredientes
        Obx(() {
          if (ingredients.isEmpty) {
            return Text(
              '* Agrega al menos un ingrediente',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // Botones de acción
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón actualizar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: Obx(() => ElevatedButton.icon(
            onPressed: (isLoading.value || isUploadingImage.value) 
                ? null 
                : _updateRecipe,
            icon: isLoading.value 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(
              isLoading.value 
                  ? 'Actualizando...' 
                  : 'Actualizar Receta',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )),
        ),
      ],
    );
  }

  // Métodos de funcionalidad
  void _showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccionar Imagen',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Cámara',
                  onTap: () => _getImage(ImageSource.camera),
                ),
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Galería',
                  onTap: () => _getImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Get.theme.primaryColor),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      Get.back(); // Cerrar bottom sheet
      isUploadingImage.value = true;

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        imageChanged.value = true;
        Get.snackbar(
          'Imagen Seleccionada',
          'Nueva imagen cargada correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al seleccionar imagen: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  void _addIngredient() {
    final ingredient = ingredientController.text.trim();
    if (ingredient.isNotEmpty && !ingredients.contains(ingredient)) {
      ingredients.add(ingredient);
      ingredientController.clear();
    } else if (ingredient.isEmpty) {
      Get.snackbar(
        'Error',
        'Escribe un ingrediente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Ingrediente Duplicado',
        'Este ingrediente ya está en la lista',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void _removeIngredient(int index) {
    if (index >= 0 && index < ingredients.length) {
      ingredients.removeAt(index);
    }
  }

  Future<void> _updateRecipe() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar ingredientes
    if (ingredients.isEmpty) {
      Get.snackbar(
        'Error',
        'Agrega al menos un ingrediente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Crear el JSON de ingredientes con descripción
      final ingredientsData = {
        'ingredients': ingredients.toList(),
        if (descriptionController.text.trim().isNotEmpty)
          'description': descriptionController.text.trim(),
      };

      String finalImageUrl = currentImageUrl.value;
      
      // Subir nueva imagen si se seleccionó una
      if (selectedImage.value != null) {
        Get.snackbar(
          'Subiendo...',
          'Subiendo nueva imagen de la receta',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
          showProgressIndicator: true,
          isDismissible: false,
          duration: const Duration(seconds: 10),
        );

        finalImageUrl = await recipeController.repository.uploadImageToStorage(
          selectedImage.value!,
        );
      }

      // Crear el modelo de receta actualizado
      final updatedRecipe = currentRecipe.copyWith(
        name: nameController.text.trim(),
        ingredients: jsonEncode(ingredientsData),
        imagePath: finalImageUrl,
      );

      // Actualizar usando el controlador
      await recipeController.updateRecipe(recipeId, updatedRecipe);

      // Cerrar snackbar de progreso
      Get.closeAllSnackbars();

      // Mostrar éxito
      Get.snackbar(
        '¡Actualizada!',
        'Receta "${updatedRecipe.name}" actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Volver a la pantalla anterior
      Get.back();

    } catch (e) {
      Get.closeAllSnackbars();
      Get.snackbar(
        'Error',
        'Error al actualizar la receta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de eliminar la receta "${currentRecipe.name}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Cerrar diálogo
              
              try {
                await recipeController.deleteRecipe(recipeId);
                
                Get.back(); // Volver a la pantalla anterior
                
                Get.snackbar(
                  'Eliminada',
                  'Receta "${currentRecipe.name}" eliminada correctamente',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Error al eliminar la receta: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}