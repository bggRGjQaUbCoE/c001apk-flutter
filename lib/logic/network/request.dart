import 'dart:async';
import 'package:dio/dio.dart';

import '../../logic/network/interceptor.dart';

class Request {
  static final Request _instance = Request._internal();
  static late final Dio dio;
  factory Request() => _instance;

  Request._internal() {
    dio = Dio()
      ..options.connectTimeout = const Duration(milliseconds: 5000)
      ..options.receiveTimeout = const Duration(milliseconds: 5000)
      ..interceptors.add(ApiInterceptor());
  }

  Future<Response<dynamic>> get(
    url, {
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    extra,
  }) async {
    return await dio.get(
      url,
      queryParameters: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> post(
    url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    extra,
  }) async {
    return await dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
