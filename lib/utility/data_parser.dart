import 'dart:isolate';
import 'package:data_parser/model/comment.dart';
import 'package:dio/dio.dart';
import '../model/base_model.dart';
import '../model/data_list_response.dart';
import '../model/data_response.dart';

class DataParser {
  static DataParser? _instance;

  static DataParser get instance {
    return _instance ??= DataParser._init();
  }

  DataParser._init();

  SendPort? _sendPort;

  ///It works if no thread has been created yet.
  ///A new thread is created with the Isolate.spawn method and the [isolate CallBack] method is activated.
  ///[sendPort] is assigned.
  Future<void> _initParsing<T extends BaseModel>() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
      _isolateCallback,
      receivePort.sendPort,
    );

    _sendPort = await receivePort.first;
  }

  ///It is created by the [initParsing] method and takes [sendPort] as a parameter.
  ///A stream is opened via [receivePort]. In this stream, the data from the [mainHandler] method (ie data from the main thread)
  ///is processed on a different thread with the [_parseModelResponse] and [_parseListResponse] methods and sent to the main thread.
  ///Each model should be enclosed in a switch case so that there is no problem in the data parse process.
  void _isolateCallback<T extends BaseModel>(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((dynamic message) {
      final parsable = message as Parsable;
      switch (parsable.type) {
        case Comment:
          parsable.sender.send(_parseListResponse<Comment>(parsable));
          break;

        default:
          final error =
              "PLEASE ADD send case for ${parsable.type} in DataParser class";
          throw UnimplementedError(error);
      }
    });
  }

  ///If [sendPort] is null (i.e. no thread has been created yet for parse operations)
  ///The [initParsing] method is called and the thread is created.
  ///The [Parsable] class is sent to the thread via the opened [sendPort] and
  ///[receivePort] is returned.
  Future<ReceivePort> _mainHandler<T extends BaseModel>(
      Response<dynamic> response) async {
    if (_sendPort == null) {
      await _initParsing();
    }
    final receivePort = ReceivePort();
    _sendPort?.send(Parsable(receivePort.sendPort, response.data, T));
    return receivePort;
  }

  ///It takes [response] and [isolation] to parse
  ///If [isolate] is sent as true and the response is successful
  ///The parse operation is directed to [mainHandler] to be performed on the thread.
  ///If response is successful and [isolate] is sent as false
  ///The parse operation is done on the main thread.
  ///In case of [response] null/fail or an exception while parsing DataResponse<T> is returned.
  Future<DataResponse<T>> parseModelResponse<T extends BaseModel>(
      Response<dynamic>? response,
      {bool isolate = true}) async {
    if (response != null) {
      try {
        if (isolate) {
          final receivePort = await _mainHandler<T>(response);
          return await receivePort.first as DataResponse<T>;
        } else {
          return DataResponse<T>.fromJson(response.data);
        }
      } catch (e) {
        return DataResponse<T>();
      }
    }
    return DataResponse<T>();
  }

  ///It takes [response] and [isolation] to parse
  ///If [isolate] is sent as true and the response is successful
  ///The list parse operation is directed to [mainHandler] to be performed on the thread.
  ///If response is successful and [isolate] is sent as false
  ///The list parse operation is done on the main thread.
  ///In case of [response] null/fail or an exception while parsing DataListResponse<T> is returned.
  Future<DataListResponse<T>> parseListResponse<T extends BaseModel>(
      Response<dynamic>? response,
      {bool isolate = true}) async {
    if (response != null) {
      try {
        if (isolate) {
          final receivePort = await _mainHandler<T>(response);
          return await receivePort.first as DataListResponse<T>;
        } else {
          return DataListResponse<T>.fromJson(response.data);
        }
      } catch (e) {
        return DataListResponse<T>();
      }
    }

    return DataListResponse<T>();
  }

  ///The incoming data is converted with fromJson and returned.
  DataResponse<T>? _parseModelResponse<T extends BaseModel>(Parsable parser) {
    try {
      final response = DataResponse<T>.fromJson(parser.map);
      return response;
    } catch (e) {
      return null;
    }
  }
	///The incoming data is converted with fromJson and returned.
  DataListResponse<T>? _parseListResponse<T extends BaseModel>(
      Parsable parser) {
    try {
      final response = DataListResponse<T>.fromJson(parser.map);
      return response;
    } catch (e) {
      return null;
    }
  }
}

///It is the class used to send data to the [isolateCallBack] thread via the main thread.
class Parsable {
  final SendPort sender;
  final dynamic map;
  final Type type;

  Parsable(this.sender, this.map, this.type);
}