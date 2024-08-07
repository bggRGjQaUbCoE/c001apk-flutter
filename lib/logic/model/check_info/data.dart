import 'package:json_annotation/json_annotation.dart';

import 'notify_count.dart';

part 'data.g.dart';

@JsonSerializable()
class Data {
  String? uid;
  String? username;
  String? token;
  // String? refreshToken;
  // int? level;
  // @JsonKey(name: 'user_type')
  // int? userType;
  // int? adminType;
  // int? subAdmin;
  // String? userAvatar;
  NotifyCount? notifyCount;
  // String? pushId;
  // SystemConfig? systemConfig;

  Data({
    this.uid,
    this.username,
    this.token,
    // this.refreshToken,
    // this.level,
    // this.userType,
    // this.adminType,
    // this.subAdmin,
    // this.userAvatar,
    this.notifyCount,
    // this.pushId,
    // this.systemConfig,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
