// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entity _$EntityFromJson(Map<String, dynamic> json) => Entity(
      entityType: json['entityType'] as String?,
      title: json['title']?.toString(),
      url: json['url'] as String?,
      pic: json['pic'] as String?,
      logo: json['logo'] as String?,
      userAvatar: json['userAvatar'] as String?,
      username: json['username'] as String?,
    );

Map<String, dynamic> _$EntityToJson(Entity instance) => <String, dynamic>{
      'entityType': instance.entityType,
      'title': instance.title,
      'url': instance.url,
      'pic': instance.pic,
      'logo': instance.logo,
      'userAvatar': instance.userAvatar,
      'username': instance.username,
    };
