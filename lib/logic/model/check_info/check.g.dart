// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInfo _$CheckInfoFromJson(Map<String, dynamic> json) => CheckInfo(
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CheckInfoToJson(CheckInfo instance) => <String, dynamic>{
      'message': instance.message,
      'data': instance.data,
    };
