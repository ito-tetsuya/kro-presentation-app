import 'package:flutter_dotenv/flutter_dotenv.dart';

class Common {

  static const hasEnv = bool.hasEnvironment('ENV');

  static String getImageUrl(String path) {
    return '${getSchema()}://${dotenv.env['API_DOMAIN']!}/$path';
  }

  static String getSchema() {
    return hasEnv ? 'https' : 'http';
  }
}
