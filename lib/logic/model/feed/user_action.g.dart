// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAction _$UserActionFromJson(Map<String, dynamic> json) => UserAction(
      like: (json['like'] as num?)?.toInt(),
      follow: (json['follow'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserActionToJson(UserAction instance) =>
    <String, dynamic>{
      'like': instance.like,
      'follow': instance.follow,
    };
