import 'package:json_annotation/json_annotation.dart';

part 'relation_row.g.dart';

@JsonSerializable()
class RelationRow {
  dynamic id;
  String? logo;
  String? title;
  String? url;
  String? entityType;
  // @JsonKey(name: 'relation_addition_logo')
  // String? relationAdditionLogo;
  // @JsonKey(name: 'relation_addition_title')
  // String? relationAdditionTitle;

  RelationRow({
    this.id,
    this.logo,
    this.title,
    this.url,
    this.entityType,
    // this.relationAdditionLogo,
    // this.relationAdditionTitle,
  });

  factory RelationRow.fromJson(Map<String, dynamic> json) {
    return _$RelationRowFromJson(json);
  }

  Map<String, dynamic> toJson() => _$RelationRowToJson(this);
}
