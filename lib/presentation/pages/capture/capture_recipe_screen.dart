import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:users_auth/controllers/recipe_controller.dart';

class CaptureRecipeScreen extends StatelessWidget {
  const CaptureRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el controlador desde GetX
    final RecipeController controller = Get.find<RecipeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capturar Receta'),        
        actions: [
          Obx(() {
            if (controller.hasImage) {
              return IconButton(
                onPressed: () => _showResetDialog(context, controller),
                icon: const Icon(Icons.refresh),
                tooltip: 'Reiniciar',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Tarjeta de estado
              _buildStatusCard(controller),
              const SizedBox(height: 20),
              
              // Contenido principal según el estado
              if (!controller.hasImage) ...[
                _buildInitialUI(controller),
              ] else ...[
                _buildImageSection(controller),
                const SizedBox(height: 20),
                _buildAnalysisSection(controller),
              ],
            ],
          ),
        );
      }),
    );
  }

  // Tarjeta de estado
  Widget _buildStatusCard(RecipeController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _getStateIcon(controller),
              color: _getStateColor(controller),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.getStateMessage(),
                style: TextStyle(
                  color: _getStateColor(controller),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (controller.isProcessing) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStateColor(controller),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // UI inicial sin imagen
  Widget _buildInitialUI(RecipeController controller) {
    return Column(
      children: [
        // Icono principal
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Get.theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(
            Icons.camera_alt,
            size: 60,
            color: Get.theme.primaryColor,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Título
        Text(
          'Capturar Nueva Receta',
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // Descripción
        Text(
          'Toma una foto de tu receta o plato de comida para analizarla con IA',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 40),
        
        // Botones de acción
        _buildActionButtons(controller),
      ],
    );
  }

  // Botones de acción
  Widget _buildActionButtons(RecipeController controller) {
    return Column(
      children: [
        // Botón para tomar foto
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: controller.isProcessing 
                ? null 
                : () => controller.captureFromCamera(),
            icon: controller.isCapturing.value 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.camera_alt),
            label: const Text('Tomar Foto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Botón para seleccionar de galería
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: controller.isProcessing 
                ? null 
                : () => controller.selectFromGallery(),
            icon: const Icon(Icons.photo_library),
            label: const Text('Seleccionar de Galería'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Get.theme.primaryColor,
              side: BorderSide(color: Get.theme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
      ],
    );
  }

  // Sección de imagen
  Widget _buildImageSection(RecipeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen Seleccionada',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Vista previa de la imagen
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: controller.selectedImage.value != null 
                ? Image.file(
                    controller.selectedImage.value!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(Icons.image, size: 64, color: Colors.grey),
                    ),
                  ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Botones de control de imagen
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: controller.isProcessing 
                  ? null 
                  : () => controller.clearCaptureData(),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton.icon(
              onPressed: (controller.canAnalyzeImage() && !controller.isAnalyzing.value) 
                  ? () => controller.analyzeImageWithAI()
                  : null,
              icon: controller.isAnalyzing.value 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(controller.isAnalyzing.value ? 'Analizando...' : 'Analizar con IA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Sección de análisis
  Widget _buildAnalysisSection(RecipeController controller) {
    if (!controller.hasAnalysis) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resultado del Análisis',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: controller.analysisResult.value!.isRecipe 
                ? _buildRecipeDetails(controller)
                : _buildErrorMessage(controller),
          ),
        ),
      ],
    );
  }

  // Detalles de la receta encontrada
  Widget _buildRecipeDetails(RecipeController controller) {
    final analysis = controller.analysisResult.value!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con ícono de éxito
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              '¡Receta Detectada!',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Nombre de la receta
        if (analysis.recipeName != null) ...[
          _buildDetailRow('Nombre:', analysis.recipeName!),
          const SizedBox(height: 12),
        ],
        
        // Descripción
        if (analysis.description != null) ...[
          _buildDetailRow('Descripción:', analysis.description!),
          const SizedBox(height: 12),
        ],
        
        // Ingredientes
        if (analysis.ingredients != null && analysis.ingredients!.isNotEmpty) ...[
          Text(
            'Ingredientes detectados:',
            style: Get.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: analysis.ingredients!.map((ingredient) => 
              Chip(
                label: Text(ingredient),
                backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: Get.theme.primaryColor,
                  fontSize: 12,
                ),
              ),
            ).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        // Botón para guardar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.isSaving.value 
                ? null 
                : () => _saveRecipe(controller),
            icon: controller.isSaving.value 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(controller.isSaving.value ? 'Guardando...' : 'Guardar Receta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // Mensaje de error cuando no es una receta
  Widget _buildErrorMessage(RecipeController controller) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No es una receta',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Text(
          controller.analysisResult.value!.message,
          style: TextStyle(
            color: Colors.orange.shade700,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => controller.clearCaptureData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Intentar con Otra Imagen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Widget helper para mostrar detalles
  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Get.textTheme.bodyMedium,
        ),
      ],
    );
  }

  // Métodos de utilidad para colores e iconos
  Color _getStateColor(RecipeController controller) {
    if (controller.isProcessing) return Colors.blue;
    if (controller.hasAnalysis && controller.analysisResult.value!.isRecipe) return Colors.green;
    if (controller.hasAnalysis && !controller.analysisResult.value!.isRecipe) return Colors.orange;
    if (controller.error.value.isNotEmpty) return Colors.red;
    return Colors.grey;
  }

  IconData _getStateIcon(RecipeController controller) {
    if (controller.isCapturing.value) return Icons.cloud_upload;
    if (controller.isAnalyzing.value) return Icons.auto_awesome;
    if (controller.isSaving.value) return Icons.save;
    if (controller.hasAnalysis && controller.analysisResult.value!.isRecipe) return Icons.check_circle;
    if (controller.hasAnalysis && !controller.analysisResult.value!.isRecipe) return Icons.warning;
    if (controller.error.value.isNotEmpty) return Icons.error;
    return Icons.camera_alt;
  }

  // Métodos de acción
  Future<void> _saveRecipe(RecipeController controller) async {
    final success = await controller.saveRecipeFromAI();
    
    if (success) {
      // Opcional: navegar de vuelta después de un delay
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.isRegistered<RecipeController>()) {
          Get.back(); // Volver a la pantalla anterior
        }
      });
    }
  }

  void _showResetDialog(BuildContext context, RecipeController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reiniciar'),
        content: const Text('¿Estás seguro de que quieres reiniciar? Se perderán todos los datos actuales.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              controller.resetCaptureState();
              Get.back();
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }
}