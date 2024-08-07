// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplyRow _$ReplyRowFromJson(Map<String, dynamic> json) => ReplyRow(
      id: json['id'],
      uid: json['uid'],
      username: json['username'] as String?,
      ruid: json['ruid'],
      rusername: json['rusername'] as String?,
      pic: json['pic'] as String?,
      picArr:
          (json['picArr'] as List<dynamic>?)?.map((e) => e as String).toList(),
      message: json['message'] as String?,
      replynum: json['replynum'],
      likenum: json['likenum'],
      dateline: json['dateline'],
      lastupdate: json['lastupdate'],
      userAction: json['userAction'] == null
          ? null
          : UserAction.fromJson(json['userAction'] as Map<String, dynamic>),
      feedUid: json['feedUid'],
      fetchType: json['fetchType'] as String?,
      entityId: json['entityId'],
      avatarFetchType: json['avatarFetchType'] as String?,
      userAvatar: json['userAvatar'] as String?,
      entityTemplate: json['entityTemplate'] as String?,
      entityType: json['entityType'] as String?,
      infoHtml: json['infoHtml'] as String?,
      isFeedAuthor: json['isFeedAuthor'],
      userInfo: json['userInfo'] == null
          ? null
          : UserInfo.fromJson(json['userInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReplyRowToJson(ReplyRow instance) => <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'username': instance.username,
      'ruid': instance.ruid,
      'rusername': instance.rusername,
      'pic': instance.pic,
      'picArr': instance.picArr,
      'message': instance.message,
      'replynum': instance.replynum,
      'likenum': instance.likenum,
      'dateline': instance.dateline,
      'lastupdate': instance.lastupdate,
      'userAction': instance.userAction,
      'feedUid': instance.feedUid,
      'fetchType': instance.fetchType,
      'entityId': instance.entityId,
      'avatarFetchType': instance.avatarFetchType,
      'userAvatar': instance.userAvatar,
      'entityTemplate': instance.entityTemplate,
      'entityType': instance.entityType,
      'infoHtml': instance.infoHtml,
      'isFeedAuthor': instance.isFeedAuthor,
      'userInfo': instance.userInfo,
    };
