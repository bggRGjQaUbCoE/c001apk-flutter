import 'package:json_annotation/json_annotation.dart';

import 'datum.dart';

part 'data_list_model.g.dart';

@JsonSerializable()
class DataListModel {
  String? message;
  List<Datum>? data;

  DataListModel({
    this.message,
    this.data,
  });

  factory DataListModel.fromJson(Map<String, dynamic> json) =>
      _$DataListModelFromJson(json);

  Map<String, dynamic> toJson() => _$DataListModelToJson(this);
}
