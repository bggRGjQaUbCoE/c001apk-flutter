import 'package:json_annotation/json_annotation.dart';

part 'extra_data_arr.g.dart';

@JsonSerializable()
class ExtraDataArr {
  // @JsonKey(name: 'cardDividerTopVX')
  // String? cardDividerTopVx;
  // @JsonKey(name: 'cardDividerBottomVX')
  // String? cardDividerBottomVx;
  // String? viewBackgroundStyle;
  // String? info;
  // int? cardId;
  String? pageTitle;
  String? cardPageName;
  // int? cardDividerBottom;

  ExtraDataArr({
    // this.cardDividerTopVx,
    // this.cardDividerBottomVx,
    // this.viewBackgroundStyle,
    // this.info,
    // this.cardId,
    this.pageTitle,
    this.cardPageName,
    // this.cardDividerBottom,
  });

  factory ExtraDataArr.fromJson(Map<String, dynamic> json) {
    return _$ExtraDataArrFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ExtraDataArrToJson(this);
}
