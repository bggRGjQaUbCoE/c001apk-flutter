// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      uid: json['uid'] as String?,
      username: json['username'] as String?,
      token: json['token'] as String?,
      // refreshToken: json['refreshToken'] as String?,
      // level: (json['level'] as num?)?.toInt(),
      // userType: (json['user_type'] as num?)?.toInt(),
      // adminType: (json['adminType'] as num?)?.toInt(),
      // subAdmin: (json['subAdmin'] as num?)?.toInt(),
      // userAvatar: json['userAvatar'] as String?,
      notifyCount: json['notifyCount'] == null
          ? null
          : NotifyCount.fromJson(json['notifyCount'] as Map<String, dynamic>),
      // pushId: json['pushId'] as String?,
      // systemConfig: json['systemConfig'] == null
      //     ? null
      //     : SystemConfig.fromJson(json['systemConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'token': instance.token,
      // 'refreshToken': instance.refreshToken,
      // 'level': instance.level,
      // 'user_type': instance.userType,
      // 'adminType': instance.adminType,
      // 'subAdmin': instance.subAdmin,
      // 'userAvatar': instance.userAvatar,
      'notifyCount': instance.notifyCount,
      // 'pushId': instance.pushId,
      // 'systemConfig': instance.systemConfig,
    };
