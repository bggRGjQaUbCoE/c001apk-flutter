import 'package:json_annotation/json_annotation.dart';

class Datum {
  int? notification;
  @JsonKey(name: 'contacts_follow')
  int? contactsFollow;
  int? message;
  int? atme;
  int? atcommentme;
  int? commentme;
  int? feedlike;
  int? badge;

  Datum({
    this.notification,
    this.contactsFollow,
    this.message,
    this.atme,
    this.atcommentme,
    this.commentme,
    this.feedlike,
    this.badge,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      notification: (json['notification'] as num?)?.toInt(),
      contactsFollow: (json['contacts_follow'] as num?)?.toInt(),
      message: (json['message'] as num?)?.toInt(),
      atme: (json['atme'] as num?)?.toInt(),
      atcommentme: (json['atcommentme'] as num?)?.toInt(),
      commentme: (json['commentme'] as num?)?.toInt(),
      feedlike: (json['feedlike'] as num?)?.toInt(),
      badge: (json['badge'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification': notification,
      'contacts_follow': contactsFollow,
      'message': message,
      'atme': atme,
      'atcommentme': atcommentme,
      'commentme': commentme,
      'feedlike': feedlike,
      'badge': badge,
    };
  }
}
