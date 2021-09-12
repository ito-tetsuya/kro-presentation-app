import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'env.dart';

class Common {
  static String getImageUrl(String path) {
    return '${Env.getSchema()}://kro-presentation-api.herokuapp.com/$path';
  }
}
