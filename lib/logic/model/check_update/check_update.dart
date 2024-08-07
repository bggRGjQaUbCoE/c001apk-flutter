import 'package:json_annotation/json_annotation.dart';

import 'datum.dart';

part 'check_update.g.dart';

@JsonSerializable()
class CheckUpdate {
  String? message;
  List<Datum>? data;

  CheckUpdate({
    this.message,
    this.data,
  });

  factory CheckUpdate.fromJson(Map<String, dynamic> json) {
    return _$CheckUpdateFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CheckUpdateToJson(this);
}
