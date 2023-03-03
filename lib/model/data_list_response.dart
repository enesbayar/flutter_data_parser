
import 'base_model.dart';

class DataListResponse<T extends BaseModel> {
  DataListResponse({
    this.result,
  });

  List<T>? result;

  factory DataListResponse.fromJson(List<dynamic>? json) => DataListResponse(
        result: json != null
            ? List<T>.from(json.map((e) => BaseModel.fromJson<T>(e)))
            : [],
      );
}