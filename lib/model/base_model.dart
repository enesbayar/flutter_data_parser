import 'package:data_parser/model/comment.dart';
import 'package:flutter/foundation.dart';

abstract class BaseModel {
  Map<String, dynamic> toJson();

  static T? fromJson<T extends BaseModel>(dynamic map) {
    switch (T) {
      case BaseModel:
        return null;
      case Comment:
        return Comment.fromJson(map) as T;
      default:
        final err = "PLEASE ADD fromJson case for $T in BaseModel class";
        debugPrint(err);
        throw UnimplementedError(err);
    }
  }
}