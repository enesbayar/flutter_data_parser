
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../model/base_model.dart';
import '../model/comment.dart';
import '../model/data_list_response.dart';
import '../model/data_response.dart';
import '../utility/data_parser.dart';

class APIClient {
  final Dio dio;

  APIClient(this.dio);

  Future<DataListResponse<Comment>?> getComments({required bool isolate}) async {
    final request = dio.options.baseUrl;
    Response? response;
    try {
      response = await dio.get(request);
    } on DioError catch (e) {
      debugPrint(e.toString());
      return null;
    }

    final result = await _handleListResponse<Comment>(response, isolate: isolate)
        as DataListResponse<Comment>;
    return result;
  }

  Future<DataResponse> _handleModelResponse<T extends BaseModel>(
    Response<dynamic>? response, {
    bool isolate = true,
  }) async {
    return DataParser.instance
        .parseModelResponse<T>(response, isolate: isolate);
  }

  Future<DataListResponse> _handleListResponse<T extends BaseModel>(
    Response<dynamic>? response, {
    bool isolate = true,
  }) async {
    return DataParser.instance.parseListResponse<T>(response, isolate: isolate);
  }
}