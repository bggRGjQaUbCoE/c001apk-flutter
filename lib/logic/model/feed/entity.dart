import 'package:json_annotation/json_annotation.dart';

part 'entity.g.dart';

@JsonSerializable()
class Entity {
  String? entityType;
  String? title;
  String? url;
  String? pic;
  String? logo;
  String? userAvatar;
  String? username;

  Entity({
    this.entityType,
    this.title,
    this.url,
    this.pic,
    this.logo,
    this.userAvatar,
    this.username,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    return _$EntityFromJson(json);
  }

  Map<String, dynamic> toJson() => _$EntityToJson(this);
}
