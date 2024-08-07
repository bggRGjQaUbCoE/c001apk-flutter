// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetRow _$TargetRowFromJson(Map<String, dynamic> json) => TargetRow(
      id: json['id'],
      logo: json['logo'] as String?,
      title: json['title'] as String?,
      url: json['url'] as String?,
      entityType: json['entityType'] as String?,
      targetType: json['targetType'] as String?,
    );

Map<String, dynamic> _$TargetRowToJson(TargetRow instance) => <String, dynamic>{
      'id': instance.id,
      'logo': instance.logo,
      'title': instance.title,
      'url': instance.url,
      'entityType': instance.entityType,
      'targetType': instance.targetType,
    };
