import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';

import 'aliyunoss_config.dart';
import 'aliyunoss_http.dart';
import 'aliyunoss_utils.dart';

/// https://github.com/kira2015/aliyunoss_plus_flutter

class AliyunOssClient {
  // 鉴权信息
  late String accessKeyId;
  late String securityToken;
  late String accessKeySecret;

  AliyunOssClient({
    required this.accessKeyId,
    required this.securityToken,
    required this.accessKeySecret,
  });
  static final StreamController<AliyunOssResult> _controller =
      StreamController.broadcast();

  ///eventStream 监听上传进度、结果
  ///@param--->>
  ///id:上传的任务id 唯一标识
  ///state上传状态 fail:上传失败 success:上传成功  uploading:上传中
  ///url:上传成功后的url
  ///msg:上传中的信息
  ///count:已经上传的大小
  ///total:文件大小
  ///partInfo:上传失败时会返回分片信息,用于断点续传
  static Stream<AliyunOssResult> get eventStream => _controller.stream;

  ///快速单个上传
  ///[id] 任务id 唯一标识
  ///[config] 阿里云鉴权信息
  ///[filePath] 文件路径
  ///[buffer] 文件数据 ,必须与ossFileName配合使用
  ///[ossFileName] oss上的文件名(如xxx.jpg) 不传默认为路径的文件名
  ///[fileNameSuffix] 返回上传文件路径时,添加文件后缀
  /// filePath与buffer不能同时为空;两者皆有时,filePath优先;filePath为空时,ossFileName不能为空;
  Future<AliyunOssResult> upload({
    required String id,
    required AliyunOssConfig config,
    String? ossFileName,
    String? filePath,
    Uint8List? buffer,
    String? fileNameSuffix,
  }) async {
    assert(filePath != null || (buffer != null && ossFileName != null));
    ossFileName ??= filePath!.split("/").last;

    String objectPath = "${config.directory}$ossFileName";

    // 转化data
    try {
      String contentMD5 = "";
      int contentLength = 0;
      dynamic data;

      // 获取文件内容
      if (filePath != null) {
        final file = File(filePath);
        final exists = await file.exists();
        final fileLength = await file.length();
        if (exists == false || fileLength <= 0) {
          return AliyunOssResult(
              id: id, state: AliyunOssResultState.fail, msg: "文件不存在");
        }

        contentMD5 = base64Encode(md5.convert(file.readAsBytesSync()).bytes);
        contentLength = fileLength;
        data = file.openRead();
      } else if (buffer?.isNotEmpty == true) {
        // 获取buffer内容
        contentMD5 = base64Encode(md5.convert(buffer!).bytes);
        contentLength = buffer.length;
        data = Stream.fromIterable(buffer.map((e) => [e]));
      } else {
        return AliyunOssResult(
            id: id, state: AliyunOssResultState.fail, msg: "文件或者数据不存在");
      }

      // 上传的到阿里云的地址
      final String requestUrl =
          'https://${config.bucket}.${config.endpoint}/$objectPath';

      // 访问数据时的域名地址
      String finallyUrl = '${config.domain}/$objectPath';
      // 增加名字后缀
      finallyUrl = addSuffix(finallyUrl, fileNameSuffix);

      // 请求时间
      final date = requestTime();
      // 请求头
      Map<String, String> headers = {
        'Content-Type':
            lookupMimeType(filePath ?? "") ?? "application/octet-stream",
        'Content-Length': contentLength.toString(),
        'Content-MD5': contentMD5,
        'Date': date,
        'Host': "${config.bucket}.${config.endpoint}",
        "x-oss-security-token": securityToken,
        "x-oss-callback-var": "eyJ4OnZhcjEiOiJmYWxzZSJ9",
        "x-oss-callback":
            "eyJjYWxsYmFja0JvZHlUeXBlIjoiYXBwbGljYXRpb25cL2pzb24iLCJjYWxsYmFja0hvc3QiOiJhcGkuY29vbGFway5jb20iLCJjYWxsYmFja1VybCI6Imh0dHBzOlwvXC9hcGkuY29vbGFway5jb21cL3Y2XC9jYWxsYmFja1wvbW9iaWxlT3NzVXBsb2FkU3VjY2Vzc0NhbGxiYWNrP2NoZWNrQXJ0aWNsZUNvdmVyUmVzb2x1dGlvbj0wJnZlcnNpb25Db2RlPTIxMDIwMzEiLCJjYWxsYmFja0JvZHkiOiJ7XCJidWNrZXRcIjoke2J1Y2tldH0sXCJvYmplY3RcIjoke29iamVjdH0sXCJoYXNQcm9jZXNzXCI6JHt4OnZhcjF9fSJ9",
      };
      headers["Authorization"] =
          sign(headers: headers, objectPath: objectPath, bucket: config.bucket);

      await Dio(BaseOptions(
              connectTimeout:
                  Duration(milliseconds: AliyunOssHttp.connectTimeout),
              sendTimeout: Duration(milliseconds: AliyunOssHttp.sendTimeout),
              receiveTimeout:
                  Duration(milliseconds: AliyunOssHttp.receiveTimeout)))
          .put(
        requestUrl,
        data: data,
        options: Options(
          headers: headers,
          responseType: ResponseType.plain,
        ),
        onSendProgress: (count, total) {
          if (count == total) {
            _controller.sink.add(AliyunOssResult(
              id: id,
              state: AliyunOssResultState.success,
              url: finallyUrl,
              count: count,
              total: total,
            ));
          } else {
            _controller.sink.add(AliyunOssResult(
              id: id,
              state: AliyunOssResultState.uploading,
              count: count,
              total: total,
            ));
          }
        },
      );
      return AliyunOssResult(
        id: id,
        state: AliyunOssResultState.success,
        url: finallyUrl,
      );
    } catch (e) {
      // 上传失败
      return AliyunOssResult(
        id: id,
        state: AliyunOssResultState.fail,
        msg: e.toString(),
      );
    }
  }
}
