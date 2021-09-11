import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as Http;

import 'common.dart';

class Request {
  static Future<Http.Response> callGetApi(String path, [Map<String, dynamic>? param]) async {
    return await _callGet(path, param);
  }

  static Future<Http.Response> callPostApi(String path, Map<String, dynamic> body) async {
    return await _call(Http.post, path, body);
  }

  static Future<Http.Response> callPutApi(String path, Map<String, dynamic> body) async {
    return await _call(Http.put, path, body);
  }

  static Future<Http.Response> callDeleteApi(String path, Map<String, dynamic> body) async {
    return await _call(Http.delete, path, body);
  }

  static Future<Http.Response> _callGet(String path, Map<String, dynamic>? param) async {
    final uri = createUri(path, param);
    return await _handleExecution(() async => await Http.get(uri));
  }

  static Future<Http.Response> _call(Function call, String path, Map<String, dynamic> body) async {
    final uri = createUri(path);
    return await _handleExecution(() async => await call(uri, body: body));
  }

  static Future<Http.Response> _handleExecution(Function call) async {
    Http.Response result = await call();
    print(result.statusCode);
    if (result.statusCode == 200) {
      return result;
    }
    throw Exception({'statusCode': result.statusCode, 'message': result.body});
  }

  static Uri createUri(String path, [Map<String, dynamic>? param]) {
    return Common.hasEnv
        ? Uri.https(dotenv.env['API_DOMAIN']!, path, param)
        : Uri.http(dotenv.env['API_DOMAIN']!, path, param);
  }

}
