import 'package:appwrite/appwrite.dart';
import 'package:users_auth/core/constants/appwrite_constants.dart';

class AppwriteConfig {
  static const String endpoint = AppwriteConstants.endpoint;
  static const String projectId = AppwriteConstants.projectId;

  static Client initClient() {
    return Client().setEndpoint(endpoint).setProject(projectId);
  }
}
