import 'datum.dart';

class OssUploadResponse {
  String? message;
  OssDatum? data;

  OssUploadResponse({
    this.message,
    this.data,
  });

  factory OssUploadResponse.fromJson(Map<String, dynamic> json) {
    return OssUploadResponse(
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : OssDatum.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data,
    };
  }
}
