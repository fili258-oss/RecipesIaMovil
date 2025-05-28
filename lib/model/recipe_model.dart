import 'dart:convert';

class RecipeModel {
  final String id;
  final String name;
  final String userId;
  final String ingredients; // JSON string de la lista de ingredientes
  final String imagePath;
  final DateTime createdAt;
  final bool active;

  RecipeModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.ingredients,
    required this.imagePath,
    required this.createdAt,
    required this.active,
  });

  // Factory constructor para crear desde JSON
  factory RecipeModel.fromJson(Map<String, dynamic> json) {        
    return RecipeModel(
      id: '${json['\$id']}',
      name: json['name'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      ingredients: json['ingredients'] ?? '[]',
      imagePath: json['image_path'] ?? json['imagePath'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      active: json['active'] ?? true,
    );
  }

  // Convertir a JSON para guardar
  Map<String, dynamic> toJson() {
    return {      
      'name': name,
      'user_id': userId,
      'ingredients': ingredients,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'active': active,
    };
  }

  // Factory constructor para crear desde análisis de IA
  factory RecipeModel.fromAIAnalysis({
    required String name,
    required String userId,
    required List<String> ingredientsList,
    required String imagePath,
    String? description,
  }) {
    // Crear objeto con ingredientes y descripción si existe
    final ingredientsData = {
      'ingredients': ingredientsList,
      if (description != null && description.isNotEmpty) 'description': description,
    };

    return RecipeModel(
      id: _generateId(),
      name: name,
      userId: userId,
      ingredients: jsonEncode(ingredientsData),
      imagePath: imagePath,
      createdAt: DateTime.now(),
      active: true,
    );
  }

  // Método para obtener la lista de ingredientes
  List<String> getIngredientsList() {
    try {
      final data = jsonDecode(ingredients);
      if (data is Map<String, dynamic> && data.containsKey('ingredients')) {
        return List<String>.from(data['ingredients']);
      } else if (data is List) {
        return List<String>.from(data);
      }
    } catch (e) {
      // Si no se puede parsear, intentar como string simple
      return ingredients.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  // Método para obtener la descripción si existe
  String? getDescription() {
    try {
      final data = jsonDecode(ingredients);
      if (data is Map<String, dynamic> && data.containsKey('description')) {
        return data['description'];
      }
    } catch (e) {
      // Si no se puede parsear, no hay descripción
    }
    return null;
  }

  // Método para crear una copia con cambios
  RecipeModel copyWith({
    String? id,
    String? name,
    String? userId,
    String? ingredients,
    String? imagePath,
    DateTime? createdAt,
    bool? active,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      ingredients: ingredients ?? this.ingredients,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
    );
  }

  // Método para validar que el modelo es válido
  bool isValid() {
    return id.isNotEmpty &&
           name.isNotEmpty &&
           userId.isNotEmpty &&
           imagePath.isNotEmpty;
  }

  // Generar ID único simple (en producción usar UUID)
  static String _generateId() {
    return 'recipe_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  @override
  String toString() {
    return 'RecipeModel(id: $id, name: $name, userId: $userId, ingredients: $ingredients, imagePath: $imagePath, createdAt: $createdAt, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

// Modelo para la respuesta del análisis de IA
class RecipeAnalysisResponse {
  final bool isRecipe;
  final String? recipeName;
  final List<String>? ingredients;
  final String message;
  final String? description;

  RecipeAnalysisResponse({
    required this.isRecipe,
    this.recipeName,
    this.ingredients,
    required this.message,
    this.description,
  });

  factory RecipeAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return RecipeAnalysisResponse(
      isRecipe: json['isRecipe'] ?? false,
      recipeName: json['recipeName'],
      ingredients: json['ingredients'] != null 
          ? List<String>.from(json['ingredients']) 
          : null,
      message: json['message'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isRecipe': isRecipe,
      'recipeName': recipeName,
      'ingredients': ingredients,
      'message': message,
      'description': description,
    };
  }

  // Convertir a RecipeModel
  RecipeModel toRecipeModel({
    required String userId,
    required String imagePath,
  }) {
    if (!isRecipe || recipeName == null) {
      throw Exception('No se puede crear RecipeModel: no es una receta válida');
    }

    return RecipeModel.fromAIAnalysis(
      name: recipeName!,
      userId: userId,
      ingredientsList: ingredients ?? [],
      imagePath: imagePath,
      description: description,
    );
  }
}