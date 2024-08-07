// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relation_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelationRow _$RelationRowFromJson(Map<String, dynamic> json) => RelationRow(
      id: json['id'],
      logo: json['logo'] as String?,
      title: json['title'] as String?,
      url: json['url'] as String?,
      entityType: json['entityType'] as String?,
    );

Map<String, dynamic> _$RelationRowToJson(RelationRow instance) =>
    <String, dynamic>{
      'id': instance.id,
      'logo': instance.logo,
      'title': instance.title,
      'url': instance.url,
      'entityType': instance.entityType,
    };
