import 'package:dio/dio.dart';
import '../models/user_model.dart';

class ApiService {
  static const String _apiKey = 'reqres-free-v1';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://reqres.in/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<UserModel>> fetchUsers({String? token}) async {
    try {
      final response = await _dio.get(
        '/users',
        options: Options(headers: {'x-api-key': _apiKey}),
      );

      final data = response.data['data'];
      return data.map<UserModel>((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  String _friendlyMessage(DioException e) {
    final status = e.response?.statusCode;
    final serverError = e.response?.data is Map
        ? e.response?.data['error']?.toString()
        : null;

    if (status == 401) {
      return '401 Unauthorized! Server error!\nReqRes rajib header x-api-key. Periksa API key.';
    }

    if (status == 403) {
      return '403 Forbidden!\nAPI key tidak valid / limit habis.';
    }

    if (status == 404) {
      return '404 Not Found! Endpoint tidak ditemukan.';
    }

    if (status != null && status >= 500) {
      return 'Server error ($status). Coba lagi nanti.';
    }

    if (serverError != null && serverError.isNotEmpty) {
      return serverError;
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Timeout: server tidak merespons. Periksa koneksi internet.';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet / server tidak terjangkau.';
      default:
        return 'Terjadi kesalahan saat mengambil data dari server.';
    }
  }
}
