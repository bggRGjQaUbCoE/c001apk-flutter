import 'package:json_annotation/json_annotation.dart';

part 'notify_count.g.dart';

@JsonSerializable()
class NotifyCount {
  // int? cloudInstall;
  int? notification;
  @JsonKey(name: 'contacts_follow')
  int? contactsFollow;
  int? message;
  int? atme;
  int? atcommentme;
  int? commentme;
  int? feedlike;
  int? badge;
  // int? dateline;

  NotifyCount({
    // this.cloudInstall,
    this.notification,
    this.contactsFollow,
    this.message,
    this.atme,
    this.atcommentme,
    this.commentme,
    this.feedlike,
    this.badge,
    // this.dateline,
  });

  factory NotifyCount.fromJson(Map<String, dynamic> json) {
    return _$NotifyCountFromJson(json);
  }

  Map<String, dynamic> toJson() => _$NotifyCountToJson(this);
}
