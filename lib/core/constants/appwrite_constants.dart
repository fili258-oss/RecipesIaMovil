class AppwriteConstants {
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '6819550c00381698589b';
  static const String databaseId = '681957e00034fa920491';
  static const String collectionId = '6819581b000fe19e2e23';
  static const String storageId = "68195bf90035496c5b07";
  static const int maxImageSize = 5 * 1024 * 1024;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Helper para generar URL pública de imagen
  static String getImageUrl(String fileId) {
    return '$endpoint/storage/buckets/$storageId/files/$fileId/view?project=$projectId';
  }
}
