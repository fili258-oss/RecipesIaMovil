import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CaptureRecipeScreen extends StatefulWidget {
  const CaptureRecipeScreen({super.key});

  @override
  State<CaptureRecipeScreen> createState() => _CaptureRecipeScreenState();
}

class _CaptureRecipeScreenState extends State<CaptureRecipeScreen> {
  final bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tomar foto de receta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono principal
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.camera_alt,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Título
            Text(
              'Capturar Nueva Receta',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Descripción
            Text(
              'Toma una foto de tu receta o escribe los ingredientes manualmente',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Botones de acción
            Column(
              children: [
                // Botón para tomar foto
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _captureFromCamera();
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tomar Foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
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
                    onPressed: () {
                      _selectFromGallery();
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Seleccionar de Galería'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botón para escribir manualmente
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton.icon(
                    onPressed: () {
                      _writeManually();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Escribir Manualmente'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _captureFromCamera() {
    // TODO: Implementar captura desde cámara
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de cámara próximamente')),
    );
  }

  void _selectFromGallery() {
    // TODO: Implementar selección desde galería
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de galería próximamente')),
    );
  }

  void _writeManually() {
    // TODO: Navegar a pantalla de escritura manual
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de escritura manual próximamente')),
    );
  }
}