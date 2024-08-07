import 'package:json_annotation/json_annotation.dart';

part 'tab_list.g.dart';

@JsonSerializable()
class TabList {
  String? title;
  String? url;
  @JsonKey(name: 'page_name')
  String? pageName;

  TabList({
    this.title,
    this.url,
    this.pageName,
  });

  factory TabList.fromJson(Map<String, dynamic> json) {
    return _$TabListFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TabListToJson(this);
}
