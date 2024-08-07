// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataListModel _$DataListModelFromJson(Map<String, dynamic> json) =>
    DataListModel(
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Datum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DataListModelToJson(DataListModel instance) =>
    <String, dynamic>{
      'message': instance.message,
      'data': instance.data,
    };
