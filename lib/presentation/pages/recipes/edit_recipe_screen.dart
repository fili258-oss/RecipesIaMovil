import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:users_auth/controllers/auth_controller.dart';
import 'package:users_auth/controllers/recipe_controller.dart';
import 'package:users_auth/data/repositories/auth_repository.dart';
import 'package:users_auth/model/recipe_model.dart';

class EditRecipeScreen extends StatelessWidget {
  final RecipeController recipeController = Get.find<RecipeController>();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;
  final String recipeId;
  
  

  EditRecipeScreen({super.key})      
      : recipeId = Get.parameters['id'] ?? '' {
    final recipe = recipeController.recipes
        .firstWhere((med) => med.id == recipeId);

    nameController.text = recipe.name;
        
  }

  // Método para mostrar diálogo de confirmación de eliminación
  void _showDeleteDialog(BuildContext context, RecipeController controller, String recipeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Está seguro de eliminar la receta "$recipeName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteRecipe(recipeId);
              Navigator.pop(context);
              Get.back();
              // Mostrar mensaje de éxito
              Get.snackbar(
                'Receta $recipeName',
                'Ha sido eliminada correctamente',
                backgroundColor: Colors.red.shade100,
                colorText: Colors.red.shade800,
                snackPosition: SnackPosition.BOTTOM,
              );
              
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

  @override
  Widget build(BuildContext context) {
    final recipeName = nameController.text;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar receta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context, recipeController, recipeName),
            
            tooltip: 'Eliminar receta',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la receta',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosis',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo requerido';
                  }
                  // Validación adicional para asegurar que es un número entero
                  if (int.tryParse(value) == null) {
                    return 'Ingrese solo números enteros';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),              
              ElevatedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final recipeTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    selectedTime.value.hour,
                    selectedTime.value.minute,
                  );

                  final recipe = RecipeModel(
                    id: recipeId,
                    name: nameController.text,
                    userId: (await Get.find<AuthRepository>().account.get()).$id,
                    ingredients: dosageController.text,
                    imagePath: '',
                    createdAt: recipeTime,
                    active: true
                    
                    
                  );

                  await recipeController.updateRecipe(recipeId, recipe);
                  
                  Get.back();
                },
                child: const Text('Actualizar receta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
