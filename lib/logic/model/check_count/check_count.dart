import 'datum.dart';

class CheckCount {
  String? message;
  Datum? data;

  CheckCount({
    this.message,
    this.data,
  });

  factory CheckCount.fromJson(Map<String, dynamic> json) {
    return CheckCount(
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : Datum.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data,
    };
  }
}
