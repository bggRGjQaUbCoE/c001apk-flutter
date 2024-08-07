import 'package:json_annotation/json_annotation.dart';

import 'data.dart';

part 'check.g.dart';

@JsonSerializable()
class CheckInfo {
  String? message;
  Data? data;

  CheckInfo({
    this.message,
    this.data,
  });

  factory CheckInfo.fromJson(Map<String, dynamic> json) =>
      _$CheckInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInfoToJson(this);
}
