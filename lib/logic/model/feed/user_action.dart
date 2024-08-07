import 'package:json_annotation/json_annotation.dart';

part 'user_action.g.dart';

@JsonSerializable()
class UserAction {
	int? like;

	UserAction({this.like});

	factory UserAction.fromJson(Map<String, dynamic> json) {
		return _$UserActionFromJson(json);
	}

	Map<String, dynamic> toJson() => _$UserActionToJson(this);
}
