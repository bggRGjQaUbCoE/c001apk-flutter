import 'package:json_annotation/json_annotation.dart';

part 'target_row.g.dart';

@JsonSerializable()
class TargetRow {
  dynamic id;
  String? logo;
  String? title;
  String? url;
  String? entityType;
  // @JsonKey(name: 'star_total_count')
  // int? starTotalCount;
  // @JsonKey(name: 'star_average_score')
  // int? starAverageScore;
  // int? isFollow;
  String? targetType;
  // @JsonKey(name: 'relation_addition_logo')
  // String? relationAdditionLogo;
  // @JsonKey(name: 'relation_addition_title')
  // String? relationAdditionTitle;
  // String? subTitle;

  TargetRow({
    this.id,
    this.logo,
    this.title,
    this.url,
    this.entityType,
    // this.starTotalCount,
    // this.starAverageScore,
    // this.isFollow,
    this.targetType,
    // this.relationAdditionLogo,
    // this.relationAdditionTitle,
    // this.subTitle,
  });

  factory TargetRow.fromJson(Map<String, dynamic> json) {
    return _$TargetRowFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TargetRowToJson(this);
}
