import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static final Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1') // Appwrite endpoint
    .setProject('6867ce2e001b592626ae'); // Your project ID

  static final Storage storage = Storage(client);
} 