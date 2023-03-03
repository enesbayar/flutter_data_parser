import 'base_model.dart';

class DataResponse<T extends BaseModel> {
  DataResponse({
    this.result,
  });

  T? result;

  factory DataResponse.fromJson(Map<String, dynamic>? json) => DataResponse(
        result: json != null
            ? BaseModel.fromJson<T>(json)
            : BaseModel.fromJson<T>(<String, dynamic>{}),
      );
}
