import 'package:dio/dio.dart';
import 'package:socialfeed/utils/network/end_points.dart';

class NetworkManager {
  final Dio _dio;

  NetworkManager() : _dio = Dio(BaseOptions(baseUrl: EndPoints.baseUrl));

  void post({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    _dio.post(endpoint, data: data);
  }

  Future get({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    var response = await _dio.get(endpoint, queryParameters: data);

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
