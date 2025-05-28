import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:users_auth/controllers/recipe_controller.dart';
import 'package:users_auth/data/repositories/auth_repository.dart';
import 'package:users_auth/model/recipe_model.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
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

  // Obtener el controlador de recetas
  RecipeController get recipeController => Get.find<RecipeController>();

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
        title: const Text('Agregar Receta')        
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
              
              // Botón guardar
              _buildSaveButton(),
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
          if (selectedImage.value != null) {
            return Column(
              children: [
                // Vista previa de la imagen
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
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
                const SizedBox(height: 8),
                
                // Botones de control
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: isUploadingImage.value 
                          ? null 
                          : () => selectedImage.value = null,
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
          } else {
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
        }),
      ],
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
                  'No hay ingredients agregados',
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
                '${ingredients.length} ingrediente(s) agregado(s):',
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

  // Botón guardar
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Obx(() => ElevatedButton.icon(
        onPressed: (isLoading.value || isUploadingImage.value) 
            ? null 
            : _saveRecipe,
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
              ? 'Guardando...' 
              : 'Guardar Receta',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      )),
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
        Get.snackbar(
          'Imagen Seleccionada',
          'Imagen cargada correctamente',
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

  Future<void> _saveRecipe() async {
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

    // Validar imagen (opcional)
    if (selectedImage.value == null) {
      final shouldContinue = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Sin Imagen'),
          content: const Text('¿Quieres guardar la receta sin imagen?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
      
      if (shouldContinue != true) return;
    }

    try {
      isLoading.value = true;

      // Crear el JSON de ingredientes con descripción
      final ingredientsData = {
        'ingredients': ingredients.toList(),
        if (descriptionController.text.trim().isNotEmpty)
          'description': descriptionController.text.trim(),
      };

      String imageUrl = '';
      
      // Subir imagen si existe
      if (selectedImage.value != null) {
        Get.snackbar(
          'Subiendo...',
          'Subiendo imagen de la receta',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
          showProgressIndicator: true,
          isDismissible: false,
          duration: const Duration(seconds: 10),
        );

        imageUrl = await recipeController.repository.uploadImageToStorage(
          selectedImage.value!,
        );
      }

      // Crear el modelo de receta
      final recipe = RecipeModel(
        id: '', // AppWrite generará el ID
        name: nameController.text.trim(),
        //(await Get.find<AuthRepository>().account.get()).$id
        userId: '',
        ingredients: jsonEncode(ingredientsData),
        imagePath: imageUrl,
        createdAt: DateTime.now(),
        active: true,
      );

      // Guardar usando el controlador
      await recipeController.addRecipe(recipe);

      // Cerrar snackbar de progreso
      Get.closeAllSnackbars();

      // Mostrar éxito
      Get.snackbar(
        '¡Éxito!',
        'Receta "${recipe.name}" guardada correctamente',
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
        'Error al guardar la receta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }
}