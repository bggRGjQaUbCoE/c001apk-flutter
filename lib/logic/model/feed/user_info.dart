import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  int? uid;
  String? username;
  int? follow;
  int? fans;
  // int? admintype;
  // int? groupid;
  // int? usergroupid;
  // int? level;
  // int? experience;
  // int? status;
  // @JsonKey(name: 'block_status')
  // int? blockStatus;
  // int? usernamestatus;
  // int? avatarstatus;
  // @JsonKey(name: 'avatar_cover_status')
  // int? avatarCoverStatus;
  // int? regdate;
  // int? logintime;
  // @JsonKey(name: 'verify_title')
  // String? verifyTitle;
  // @JsonKey(name: 'verify_status')
  // int? verifyStatus;
  // @JsonKey(name: 'user_type')
  // int? userType;
  // @JsonKey(name: 'verify_show_type')
  // int? verifyShowType;
  // @JsonKey(name: 'avatar_plugin_status')
  // int? avatarPluginStatus;
  // String? fetchType;
  // String? entityType;
  // int? entityId;
  // String? displayUsername;
  // String? url;
  String? userAvatar;
  // String? userSmallAvatar;
  // String? userBigAvatar;
  // String? cover;
  // @JsonKey(name: 'verify_icon')
  // String? verifyIcon;
  // @JsonKey(name: 'verify_label')
  // String? verifyLabel;
  // int? isDeveloper;
  // @JsonKey(name: 'next_level_experience')
  // int? nextLevelExperience;
  // @JsonKey(name: 'next_level_percentage')
  // String? nextLevelPercentage;
  // @JsonKey(name: 'level_today_message')
  // String? levelTodayMessage;
  // @JsonKey(name: 'level_detail_url')
  // String? levelDetailUrl;
  // @JsonKey(name: 'avatar_plugin_url')
  // String? avatarPluginUrl;
  // @JsonKey(name: 'feed_plugin_url')
  // String? feedPluginUrl;
  // @JsonKey(name: 'feed_plugin_open_url')
  // String? feedPluginOpenUrl;
  // @JsonKey(name: 'feed_reply_plugin')
  // String? feedReplyPlugin;
  // @JsonKey(name: 'feed_reply_plugin_open_url')
  // String? feedReplyPluginOpenUrl;

  UserInfo({
    this.uid,
    this.username,
    this.follow,
    this.fans,
    // this.admintype,
    // this.groupid,
    // this.usergroupid,
    // this.level,
    // this.experience,
    // this.status,
    // this.blockStatus,
    // this.usernamestatus,
    // this.avatarstatus,
    // this.avatarCoverStatus,
    // this.regdate,
    // this.logintime,
    // this.verifyTitle,
    // this.verifyStatus,
    // this.userType,
    // this.verifyShowType,
    // this.avatarPluginStatus,
    // this.fetchType,
    // this.entityType,
    // this.entityId,
    // this.displayUsername,
    // this.url,
    this.userAvatar,
    // this.userSmallAvatar,
    // this.userBigAvatar,
    // this.cover,
    // this.verifyIcon,
    // this.verifyLabel,
    // this.isDeveloper,
    // this.nextLevelExperience,
    // this.nextLevelPercentage,
    // this.levelTodayMessage,
    // this.levelDetailUrl,
    // this.avatarPluginUrl,
    // this.feedPluginUrl,
    // this.feedPluginOpenUrl,
    // this.feedReplyPlugin,
    // this.feedReplyPluginOpenUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return _$UserInfoFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
