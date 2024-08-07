import 'package:json_annotation/json_annotation.dart';

part 'datum.g.dart';

@JsonSerializable()
class Datum {
  int? id;
  // int? catid;
  String? title;
  // String? shorttitle;
  String? logo;
  // String? cover;
  // @JsonKey(name: 'open_link')
  // String? openLink;
  // String? version;
  // int? digest;
  // int? recommend;
  // int? favnum;
  // int? ishp;
  // int? ishot;
  // int? isbiz;
  // int? iscps;
  // @JsonKey(name: 'is_coolapk_cpa')
  // int? isCoolapkCpa;
  // int? apktype;
  // String? apkname;
  // String? apkname2;
  String? apkversionname;
  int? apkversioncode;
  // int? apklength;
  String? apksize;
  // String? apkmd5;
  // int? sdkversion;
  // String? romversion;
  // String? hotlabel;
  // String? shortlabel;
  // String? keywords;
  // String? description;
  // int? developeruid;
  // String? developername;
  // int? star;
  // String? score;
  // String? adminscore;
  // int? downnum;
  // int? follownum;
  // int? votenum;
  // int? commentnum;
  // int? replynum;
  // @JsonKey(name: 'comment_block_num')
  // int? commentBlockNum;
  // @JsonKey(name: 'hot_num')
  // int? hotNum;
  // int? pubdate;
  // @JsonKey(name: 'comment_status')
  // int? commentStatus;
  int? lastupdate;
  // @JsonKey(name: 'last_comment_update')
  // int? lastCommentUpdate;
  // @JsonKey(name: 'is_forum_app')
  // int? isForumApp;
  // @JsonKey(name: 'allow_rating')
  // int? allowRating;
  // @JsonKey(name: 'get_timewit_cpc')
  // int? getTimewitCpc;
  // int? status;
  // @JsonKey(name: 'rta_callback')
  // String? rtaCallback;
  // String? entityType;
  // int? entityId;
  String? packageName;
  // String? shortTags;
  // String? apkTypeName;
  // String? apkTypeUrl;
  // String? apkUrl;
  // String? url;
  // String? catDir;
  // String? catName;
  // String? downCount;
  // String? followCount;
  // int? voteCount;
  // String? commentCount;
  // int? replyCount;
  // @JsonKey(name: 'hot_num_txt')
  // String? hotNumTxt;
  // String? updateFlag;
  // String? extraFlag;
  // String? apkRomVersion;
  // String? statusText;
  // String? pubStatusText;
  // String? commentStatusText;
  // @JsonKey(name: 'target_id')
  // String? targetId;
  // String? votescore;
  // @JsonKey(name: 'rating_star')
  // double? ratingStar;
  String? changelog;
  @JsonKey(name: 'pkg_bit_type')
  int? pkgBitType;

  Datum({
    this.id,
    // this.catid,
    this.title,
    // this.shorttitle,
    this.logo,
    // this.cover,
    // this.openLink,
    // this.version,
    // this.digest,
    // this.recommend,
    // this.favnum,
    // this.ishp,
    // this.ishot,
    // this.isbiz,
    // this.iscps,
    // this.isCoolapkCpa,
    // this.apktype,
    // this.apkname,
    // this.apkname2,
    this.apkversionname,
    this.apkversioncode,
    // this.apklength,
    this.apksize,
    // this.apkmd5,
    // this.sdkversion,
    // this.romversion,
    // this.hotlabel,
    // this.shortlabel,
    // this.keywords,
    // this.description,
    // this.developeruid,
    // this.developername,
    // this.star,
    // this.score,
    // this.adminscore,
    // this.downnum,
    // this.follownum,
    // this.votenum,
    // this.commentnum,
    // this.replynum,
    // this.commentBlockNum,
    // this.hotNum,
    // this.pubdate,
    // this.commentStatus,
    this.lastupdate,
    // this.lastCommentUpdate,
    // this.isForumApp,
    // this.allowRating,
    // this.getTimewitCpc,
    // this.status,
    // this.rtaCallback,
    // this.entityType,
    // this.entityId,
    this.packageName,
    // this.shortTags,
    // this.apkTypeName,
    // this.apkTypeUrl,
    // this.apkUrl,
    // this.url,
    // this.catDir,
    // this.catName,
    // this.downCount,
    // this.followCount,
    // this.voteCount,
    // this.commentCount,
    // this.replyCount,
    // this.hotNumTxt,
    // this.updateFlag,
    // this.extraFlag,
    // this.apkRomVersion,
    // this.statusText,
    // this.pubStatusText,
    // this.commentStatusText,
    // this.targetId,
    // this.votescore,
    // this.ratingStar,
    this.changelog,
    this.pkgBitType,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => _$DatumFromJson(json);

  Map<String, dynamic> toJson() => _$DatumToJson(this);
}
