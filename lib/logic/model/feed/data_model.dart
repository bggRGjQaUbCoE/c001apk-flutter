import 'package:json_annotation/json_annotation.dart';

import 'datum.dart';

part 'data_model.g.dart';

@JsonSerializable()
class DataModel {
  String? message;
  Datum? data;

  DataModel({
    this.message,
    this.data,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) =>
      _$DataModelFromJson(json);

  Map<String, dynamic> toJson() => _$DataModelToJson(this);
}
