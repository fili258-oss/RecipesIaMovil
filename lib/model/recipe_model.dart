class RecipeModel {
  final String id;
  final String name;
  final String userId;
  final String ingredients;
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


  Map<String, dynamic> toJson() => {
    'name': name,
    'user_id': userId,
    'ingredients': ingredients,
    'image_path': imagePath,
    'created_at': createdAt.toIso8601String(),
    'active': active,
  };

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['\$id'],  // Cambiado para tomar el id interno, que puede ser null
      name: json['name'] ?? '',
      userId: json['user_id'] ?? '',
      ingredients: json['ingredients'] ?? '',
      imagePath: json['image_path'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(), // O cualquier default
      active: json['active'] ?? true,
    );
  }
  
}