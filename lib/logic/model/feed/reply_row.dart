import 'package:json_annotation/json_annotation.dart';

import 'user_action.dart';
import 'user_info.dart';

part 'reply_row.g.dart';

@JsonSerializable()
class ReplyRow {
  dynamic id;
  // int? ftype;
  // int? fid;
  // int? rid;
  // int? rrid;
  dynamic uid;
  String? username;
  dynamic ruid;
  String? rusername;
  String? pic;
  List<String>? picArr;
  String? message;
  dynamic replynum;
  dynamic likenum;
  // int? burynum;
  // int? reportnum;
  // @JsonKey(name: 'rank_score')
  // int? rankScore;
  dynamic dateline;
  dynamic lastupdate;
  // @JsonKey(name: 'is_folded')
  // int? isFolded;
  // int? status;
  // @JsonKey(name: 'message_status')
  // int? messageStatus;
  // @JsonKey(name: 'block_status')
  // int? blockStatus;
  // @JsonKey(name: 'recent_reply_ids')
  // String? recentRe/plyIds;
  // @JsonKey(name: 'include_goods_ids')
  // String? includeGoodsIds;
  UserAction? userAction;
  dynamic feedUid;
  String? fetchType;
  dynamic entityId;
  String? avatarFetchType;
  String? userAvatar;
  String? entityTemplate;
  String? entityType;
  String? infoHtml;
  dynamic isFeedAuthor;
  // @JsonKey(name: 'extra_fromApi')
  // String? extraFromApi;
  UserInfo? userInfo;
  // String? extraFlag;

  ReplyRow({
    this.id,
    // this.ftype,
    // this.fid,
    // this.rid,
    // this.rrid,
    this.uid,
    this.username,
    this.ruid,
    this.rusername,
    this.pic,
    this.picArr,
    this.message,
    this.replynum,
    this.likenum,
    // this.burynum,
    // this.reportnum,
    // this.rankScore,
    this.dateline,
    this.lastupdate,
    // this.isFolded,
    // this.status,
    // this.messageStatus,
    // this.blockStatus,
    // this.recentReplyIds,
    // this.includeGoodsIds,
    this.userAction,
    this.feedUid,
    this.fetchType,
    this.entityId,
    this.avatarFetchType,
    this.userAvatar,
    this.entityTemplate,
    this.entityType,
    this.infoHtml,
    this.isFeedAuthor,
    // this.extraFromApi,
    this.userInfo,
    // this.extraFlag,
  });

  factory ReplyRow.fromJson(Map<String, dynamic> json) {
    return _$ReplyRowFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ReplyRowToJson(this);
}
