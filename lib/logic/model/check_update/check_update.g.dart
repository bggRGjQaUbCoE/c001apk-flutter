// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckUpdate _$CheckUpdateFromJson(Map<String, dynamic> json) => CheckUpdate(
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Datum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CheckUpdateToJson(CheckUpdate instance) =>
    <String, dynamic>{
      'message': instance.message,
      'data': instance.data,
    };
