// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notify_count.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotifyCount _$NotifyCountFromJson(Map<String, dynamic> json) => NotifyCount(
      // cloudInstall: (json['cloudInstall'] as num?)?.toInt(),
      notification: (json['notification'] as num?)?.toInt(),
      contactsFollow: (json['contacts_follow'] as num?)?.toInt(),
      message: (json['message'] as num?)?.toInt(),
      atme: (json['atme'] as num?)?.toInt(),
      atcommentme: (json['atcommentme'] as num?)?.toInt(),
      commentme: (json['commentme'] as num?)?.toInt(),
      feedlike: (json['feedlike'] as num?)?.toInt(),
      badge: (json['badge'] as num?)?.toInt(),
      // dateline: (json['dateline'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NotifyCountToJson(NotifyCount instance) =>
    <String, dynamic>{
      // 'cloudInstall': instance.cloudInstall,
      'notification': instance.notification,
      'contacts_follow': instance.contactsFollow,
      'message': instance.message,
      'atme': instance.atme,
      'atcommentme': instance.atcommentme,
      'commentme': instance.commentme,
      'feedlike': instance.feedlike,
      'badge': instance.badge,
      // 'dateline': instance.dateline,
    };
