import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../utils/snackbar_util.dart';

class ApiService {
  static ApiService? _instance;
  late final Dio _dio;
  static const bool _enableApiLogs = true;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ensure baseUrl is always the latest one
          options.baseUrl = ApiConstants.baseUrl;

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.keyToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          final langCode = prefs.getString(AppConstants.keyLanguage) ?? 'en';
          options.headers['Accept-Language'] = langCode;

          _logRequest(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          handler.next(response);
        },
        onError: (DioException e, handler) {
          _logError(e);
          _handleError(e);
          handler.next(e);
        },
      ),
    );
  }

  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  void _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      SnackbarUtil.error('Session expired. Please login again.');
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      SnackbarUtil.error('Connection timed out. Please try again.');
    } else if (e.type == DioExceptionType.connectionError) {
      SnackbarUtil.error('No internet connection.');
    }
  }

  Map<String, dynamic>? _safeResponseMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  void _logRequest(RequestOptions options) {
    if (!kDebugMode || !_enableApiLogs) return;

    final buffer = StringBuffer()
      ..writeln('================ API REQUEST ================')
      ..writeln('${options.method} ${options.uri}');

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('Query: ${_pretty(options.queryParameters)}');
    }

    if (options.data != null) {
      buffer.writeln('Payload: ${_pretty(_normalizeData(options.data))}');
    } else {
      buffer.writeln('Payload: null');
    }

    buffer.writeln('=============================================');
    debugPrint(buffer.toString());
  }

  void _logResponse(Response response) {
    if (!kDebugMode || !_enableApiLogs) return;

    final buffer = StringBuffer()
      ..writeln('================ API RESPONSE ===============')
      ..writeln('${response.requestOptions.method} ${response.requestOptions.uri}')
      ..writeln('Status: ${response.statusCode}')
      ..writeln('Response: ${_pretty(response.data)}')
      ..writeln('=============================================');

    debugPrint(buffer.toString());
  }

  void _logError(DioException e) {
    if (!kDebugMode || !_enableApiLogs) return;

    final buffer = StringBuffer()
      ..writeln('================ API ERROR ==================')
      ..writeln('${e.requestOptions.method} ${e.requestOptions.uri}')
      ..writeln('Type: ${e.type}')
      ..writeln('Status: ${e.response?.statusCode ?? 'N/A'}')
      ..writeln('Error Response: ${_pretty(e.response?.data)}')
      ..writeln('=============================================');

    debugPrint(buffer.toString());
  }

  dynamic _normalizeData(dynamic data) {
    if (data is FormData) {
      final fields = <String, dynamic>{};
      for (final entry in data.fields) {
        fields[entry.key] = entry.value;
      }

      final files = <String, dynamic>{};
      for (final entry in data.files) {
        files[entry.key] = entry.value.filename ?? 'file';
      }

      return {
        'fields': fields,
        'files': files,
      };
    }
    return data;
  }

  String _pretty(dynamic data) {
    if (data == null) return 'null';
    if (data is String) return data;

    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  // ── GET ──────────────────────────────────────────────────
  Future<Map<String, dynamic>?> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return _safeResponseMap(response.data);
    } on DioException catch (e) {
      return _safeResponseMap(e.response?.data);
    } catch (e) {
      return null;
    }
  }

  // ── POST ─────────────────────────────────────────────────
  Future<Map<String, dynamic>?> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return _safeResponseMap(response.data);
    } on DioException catch (e) {
      return _safeResponseMap(e.response?.data);
    } catch (e) {
      return null;
    }
  }

  // ── PUT ──────────────────────────────────────────────────
  Future<Map<String, dynamic>?> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return _safeResponseMap(response.data);
    } on DioException catch (e) {
      return _safeResponseMap(e.response?.data);
    } catch (e) {
      return null;
    }
  }

  // ── DELETE ───────────────────────────────────────────────
  Future<Map<String, dynamic>?> delete(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.delete(endpoint, data: data);
      return _safeResponseMap(response.data);
    } on DioException catch (e) {
      return _safeResponseMap(e.response?.data);
    } catch (e) {
      return null;
    }
  }

  // ── Helper: check success ────────────────────────────────
  static bool isSuccess(Map<String, dynamic>? response) {
    if (response == null) return false;
    if (response['IsSuccess'] == false || response['isSuccess'] == false || response['status'] == false || response['success'] == false) {
      return false;
    }
    return response['IsSuccess'] == true ||
        response['isSuccess'] == true ||
        response['status'] == true ||
        response['status'] == 200 ||
        response['statusCode'] == 200 ||
        response['success'] == true ||
        response.containsKey('Data') ||
        response.containsKey('data') ||
        response.containsKey('boy') ||
        response.containsKey('varna') ||
        response.containsKey('score') ||
        response.containsKey('total_points');
  }

  static dynamic getData(Map<String, dynamic>? response) {
    if (response == null) return null;
    if (response.containsKey('Data') && response['Data'] != null) return response['Data'];
    if (response.containsKey('data') && response['data'] != null) return response['data'];
    return response;
  }

  static String getMessage(Map<String, dynamic>? response) {
    return response?['Message'] ?? response?['message'] ?? response?['msg'] ?? response?['error'] ?? 'Something went wrong';
  }
}
