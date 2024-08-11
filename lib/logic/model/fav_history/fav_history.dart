import 'package:hive/hive.dart';

part 'fav_history.g.dart';

@HiveType(typeId: 0)
class FavHistoryItem {
  FavHistoryItem({
    this.id,
    this.uid,
    this.username,
    this.userAvatar,
    this.message,
    this.device,
    this.dateline,
    this.time,
  });

  @HiveField(0)
  String? id;
  @HiveField(1)
  String? uid;
  @HiveField(2)
  String? username;
  @HiveField(3)
  String? userAvatar;
  @HiveField(4)
  String? message;
  @HiveField(5)
  String? device;
  @HiveField(6)
  String? dateline;
  @HiveField(7)
  int? time;

  FavHistoryItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    username = json['username'];
    userAvatar = json['userAvatar'];
    message = json['message'];
    device = json['device'];
    dateline = json['dateline'];
    time = json['time'];
  }
}
