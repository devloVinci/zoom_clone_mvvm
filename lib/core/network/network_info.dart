import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@injectable
class NetworkInfo {
  final Dio _dio;

  NetworkInfo(this._dio);

  Future<bool> get isConnected async {
    try {
      final response = await _dio.get('https://www.google.com');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
