import 'package:json_annotation/json_annotation.dart';

import 'entity.dart';
import 'extra_data_arr.dart';
import 'relation_row.dart';
import 'tab_list.dart';
import 'target_row.dart';
import 'user_action.dart';
import 'user_info.dart';

part 'datum.g.dart';

@JsonSerializable()
class Datum {
  dynamic entityId;
  String? entityType;
  String? entityTemplate;
  String? title;
  String? url;
  List<Entity>? entities;
  // int? entityId;
  // int? entityFixed;
  String? pic;
  dynamic lastupdate;
  ExtraDataArr? extraDataArr;
  // String? extraData;
  dynamic id;
  dynamic type;
  // int? fid;
  // String? forwardid;
  // @JsonKey(name: 'source_id')
  // String? sourceId;
  dynamic uid;
  dynamic ruid;
  String? username;
  String? rusername;
  // @JsonKey(name: 'dyh_id')
  // int? dyhId;
  // @JsonKey(name: 'dyh_name')
  // String? dyhName;
  // int? ttype;
  // int? tcat;
  // int? tid;
  String? ttitle;
  // String? tpic;
  // String? turl;
  // String? tinfo;
  @JsonKey(name: 'message_title')
  String? messageTitle;
  // @JsonKey(name: 'message_title_md5')
  // String? messageTitleMd5;
  // @JsonKey(name: 'message_keywords')
  // String? messageKeywords;
  @JsonKey(name: 'message_cover')
  String? messageCover;
  String? message;
  // @JsonKey(name: 'message_length')
  // int? messageLength;
  // int? issummary;
  // int? istag;
  // @JsonKey(name: 'is_html_article')
  // int? isHtmlArticle;
  String? tags;
  // String? label;
  // @JsonKey(name: 'user_tags')
  // String? userTags;
  // @JsonKey(name: 'media_type')
  // int? mediaType;
  // @JsonKey(name: 'media_pic')
  // String? mediaPic;
  // @JsonKey(name: 'media_url')
  // String? mediaUrl;
  // @JsonKey(name: 'extra_type')
  // int? extraType;
  // @JsonKey(name: 'extra_key')
  // String? extraKey;
  @JsonKey(name: 'extra_title')
  String? extraTitle;
  @JsonKey(name: 'extra_url')
  String? extraUrl;
  @JsonKey(name: 'extra_pic')
  String? extraPic;
  // @JsonKey(name: 'extra_info')
  // String? extraInfo;
  // @JsonKey(name: 'extra_status')
  // int? extraStatus;
  // String? location;
  // int? fromid;
  // String? fromname;
  dynamic likenum;
  // int? burynum;
  dynamic commentnum;
  dynamic replynum;
  // int? forwardnum;
  // int? reportnum;
  // int? relatednum;
  // int? favnum;
  // @JsonKey(name: 'share_num')
  // int? shareNum;
  // @JsonKey(name: 'comment_block_num')
  // int? commentBlockNum;
  // @JsonKey(name: 'question_answer_num')
  // int? questionAnswerNum;
  // @JsonKey(name: 'question_follow_num')
  // int? questionFollowNum;
  // int? hitnum;
  // int? viewnum;
  // @JsonKey(name: 'feed_score')
  // int? feedScore;
  // @JsonKey(name: 'rank_score')
  // int? rankScore;
  // @JsonKey(name: 'vote_score')
  // int? voteScore;
  // @JsonKey(name: 'at_count')
  // int? atCount;
  // @JsonKey(name: 'url_count')
  // int? urlCount;
  // @JsonKey(name: 'tag_count')
  // int? tagCount;
  // @JsonKey(name: 'change_count')
  // int? changeCount;
  // int? recommend;
  // @JsonKey(name: 'is_anonymous')
  // int? isAnonymous;
  // @JsonKey(name: 'is_hidden')
  // int? isHidden;
  // @JsonKey(name: 'is_headline')
  // int? isHeadline;
  // @JsonKey(name: 'disallow_reply')
  // int? disallowReply;
  // int? status;
  // @JsonKey(name: 'block_status')
  // int? blockStatus;
  // @JsonKey(name: 'message_status')
  // int? messageStatus;
  // @JsonKey(name: 'publish_status')
  // int? publishStatus;
  dynamic dateline;
  // @JsonKey(name: 'create_time')
  // int? createTime;
  // @JsonKey(name: 'last_change_time')
  // int? lastChangeTime;
  @JsonKey(name: 'device_title')
  String? deviceTitle;
  // @JsonKey(name: 'device_name')
  // String? deviceName;
  // @JsonKey(name: 'device_rom')
  // String? deviceRom;
  // @JsonKey(name: 'device_build')
  // String? deviceBuild;
  // @JsonKey(name: 'recent_reply_ids')
  // String? recentReplyIds;
  // @JsonKey(name: 'recent_hot_reply_ids')
  // String? recentHotReplyIds;
  // @JsonKey(name: 'recent_like_list')
  // String? recentLikeList;
  // @JsonKey(name: 'related_dyh_ids')
  // String? relatedDyhIds;
  // @JsonKey(name: 'post_signature')
  // String? postSignature;
  // @JsonKey(name: 'message_signature')
  // String? messageSignature;
  String? fetchType;
  // String? avatarFetchType;
  String? userAvatar;
  // @JsonKey(name: 'is_pre_recommended')
  // int? isPreRecommended;
  String? feedType;
  String? feedTypeName;
  // String? turlTarget;
  // int? isModified;
  @JsonKey(name: 'ip_location')
  String? ipLocation;
  // int? enableModify;
  // String? info;
  String? infoHtml;
  List<String>? picArr;
  // @JsonKey(name: 'device_title_url')
  // String? deviceTitleUrl;
  // List<dynamic>? relateddata;
  // @JsonKey(name: 'media_info')
  // String? mediaInfo;
  // String? shareUrl;
  // @JsonKey(name: 'extra_fromApi')
  // String? extraFromApi;
  dynamic sourceFeed;
  String? forwardSourceType;
  Datum? forwardSourceFeed;
  // int? canDisallowReply;
  // @JsonKey(name: 'disallow_repost')
  // int? disallowRepost;
  // @JsonKey(name: 'long_location')
  // String? longLocation;
  // @JsonKey(name: 'is_white_feed')
  // int? isWhiteFeed;
  // @JsonKey(name: 'editor_title')
  // String? editorTitle;
  // @JsonKey(name: 'top_reply_ids')
  // List<dynamic>? topReplyIds;
  // @JsonKey(name: 'is_ks_doc')
  // int? isKsDoc;
  List<Datum>? replyRows;
  List<Datum>? topReplyRows;
  List<Datum>? replyMeRows;
  // int? replyRowsCount;
  int? replyRowsMore;
  UserInfo? userInfo;
  UserInfo? fUserInfo;
  UserInfo? likeUserInfo;
  List<RelationRow>? relationRows;
  TargetRow? targetRow;
  // String? pickType;
  // @JsonKey(name: '_tid')
  // int? tid1;
  UserAction? userAction;
  // @JsonKey(name: 'include_goods_ids')
  // List<String>? includeGoodsIds;
  String? cover;
  @JsonKey(name: 'cover_pic')
  String? coverPic;
  dynamic level;
  dynamic follow;
  @JsonKey(name: 'be_like_num')
  dynamic beLikeNum;
  dynamic fans;
  dynamic logintime;
  dynamic regdate;
  String? bio;
  dynamic feed;
  dynamic gender;
  String? logo;
  String? apkversionname;
  dynamic apkversioncode;
  String? apksize;
  @JsonKey(name: 'comment_status')
  dynamic commentStatus;
  String? commentStatusText;
  List<TabList>? tabList;
  String? selectedTab;
  @JsonKey(name: 'target_type_title')
  String? targetTypeTitle;
  @JsonKey(name: 'hot_num_txt')
  dynamic hotNumTxt;
  @JsonKey(name: 'follow_num')
  dynamic followNum;
  dynamic downCount;
  @JsonKey(name: 'feed_comment_num_txt')
  dynamic feedCommentNumTxt;
  @JsonKey(name: 'commentnum_txt')
  dynamic commentnumTxt;
  @JsonKey(name: 'target_type')
  String? targetType;
  @JsonKey(name: 'fans_num')
  dynamic fansNum;
  @JsonKey(name: 'comment_num')
  dynamic commentNum;
  int? feedUid;
  @JsonKey(name: 'message_raw_output')
  String? messageRawOutput;
  int? isStickTop;
  dynamic experience;
  @JsonKey(name: 'next_level_experience')
  int? nextLevelExperience;
  String? fromUserAvatar;
  String? fromusername;
  int? fromuid;
  String? note;
  dynamic likeTime;
  @JsonKey(name: 'message_pic')
  String? messagePic;
  String? messageUserAvatar;
  int? messageUid;
  String? messageUsername;
  int? unreadNum;
  @JsonKey(name: 'is_top')
  int? isTop;
  String? ukey;
  String? description;
  @JsonKey(name: 'is_open_title')
  String? isOpenTitle;
  @JsonKey(name: 'item_num')
  int? itemNum;
  dynamic isFollow;

  Datum({
    this.entityId,
    this.entityType,
    this.entityTemplate,
    this.title,
    this.url,
    this.entities,
    // this.entityId,
    // this.entityFixed,
    this.pic,
    this.lastupdate,
    this.extraDataArr,
    // this.extraData,
    this.id,
    this.type,
    // this.fid,
    // this.forwardid,
    // this.sourceId,
    this.uid,
    this.ruid,
    this.username,
    this.rusername,
    // this.dyhId,
    // this.dyhName,
    // this.ttype,
    // this.tcat,
    // this.tid,
    this.ttitle,
    // this.tpic,
    // this.turl,
    // this.tinfo,
    this.messageTitle,
    // this.messageTitleMd5,
    // this.messageKeywords,
    this.messageCover,
    this.message,
    // this.messageLength,
    // this.issummary,
    // this.istag,
    // this.isHtmlArticle,
    this.tags,
    // this.label,
    // this.userTags,
    // this.mediaType,
    // this.mediaPic,
    // this.mediaUrl,
    // this.extraType,
    // this.extraKey,
    this.extraTitle,
    this.extraUrl,
    this.extraPic,
    // this.extraInfo,
    // this.extraStatus,
    // this.location,
    // this.fromid,
    // this.fromname,
    this.likenum,
    // this.burynum,
    this.commentnum,
    this.replynum,
    // this.forwardnum,
    // this.reportnum,
    // this.relatednum,
    // this.favnum,
    // this.shareNum,
    // this.commentBlockNum,
    // this.questionAnswerNum,
    // this.questionFollowNum,
    // this.hitnum,
    // this.viewnum,
    // this.feedScore,
    // this.rankScore,
    // this.voteScore,
    // this.atCount,
    // this.urlCount,
    // this.tagCount,
    // this.changeCount,
    // this.recommend,
    // this.isAnonymous,
    // this.isHidden,
    // this.isHeadline,
    // this.disallowReply,
    // this.status,
    // this.blockStatus,
    // this.messageStatus,
    // this.publishStatus,
    this.dateline,
    // this.createTime,
    // this.lastChangeTime,
    this.deviceTitle,
    // this.deviceName,
    // this.deviceRom,
    // this.deviceBuild,
    // this.recentReplyIds,
    // this.recentHotReplyIds,
    // this.recentLikeList,
    // this.relatedDyhIds,
    // this.postSignature,
    // this.messageSignature,
    this.fetchType,
    // this.avatarFetchType,
    this.userAvatar,
    // this.isPreRecommended,
    this.feedType,
    this.feedTypeName,
    // this.turlTarget,
    // this.isModified,
    this.ipLocation,
    // this.enableModify,
    // this.info,
    this.infoHtml,
    this.picArr,
    // this.deviceTitleUrl,
    // this.relateddata,
    // this.mediaInfo,
    // this.shareUrl,
    // this.extraFromApi,
    this.sourceFeed,
    this.forwardSourceType,
    this.forwardSourceFeed,
    // this.canDisallowReply,
    // this.disallowRepost,
    // this.longLocation,
    // this.isWhiteFeed,
    // this.editorTitle,
    // this.topReplyIds,
    // this.isKsDoc,
    this.replyRows,
    this.topReplyRows,
    this.replyMeRows,
    // this.replyRowsCount,
    this.replyRowsMore,
    this.userInfo,
    this.fUserInfo,
    this.likeUserInfo,
    this.relationRows,
    this.targetRow,
    // this.pickType,
    // this.tid1,
    this.userAction,
    // this.includeGoodsIds,
    this.cover,
    this.coverPic,
    this.level,
    this.follow,
    this.beLikeNum,
    this.fans,
    this.logintime,
    this.regdate,
    this.bio,
    this.feed,
    this.gender,
    this.logo,
    this.apkversionname,
    this.apkversioncode,
    this.apksize,
    this.commentStatus,
    this.commentStatusText,
    this.tabList,
    this.selectedTab,
    this.targetTypeTitle,
    this.hotNumTxt,
    this.followNum,
    this.downCount,
    this.feedCommentNumTxt,
    this.commentnumTxt,
    this.targetType,
    this.fansNum,
    this.commentNum,
    this.feedUid,
    this.messageRawOutput,
    this.isStickTop,
    this.experience,
    this.nextLevelExperience,
    this.fromUserAvatar,
    this.fromusername,
    this.fromuid,
    this.note,
    this.likeTime,
    this.messagePic,
    this.messageUserAvatar,
    this.messageUid,
    this.messageUsername,
    this.unreadNum,
    this.isTop,
    this.ukey,
    this.description,
    this.isOpenTitle,
    this.itemNum,
    this.isFollow,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => _$DatumFromJson(json);

  Map<String, dynamic> toJson() => _$DatumToJson(this);
}
