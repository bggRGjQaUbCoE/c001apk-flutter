import 'package:json_annotation/json_annotation.dart';

part 'system_config.g.dart';

@JsonSerializable()
class SystemConfig {
	@JsonKey(name: 'system_config') 
	String? systemConfig;
	@JsonKey(name: 'spam_word_config') 
	String? spamWordConfig;

	SystemConfig({this.systemConfig, this.spamWordConfig});

	factory SystemConfig.fromJson(Map<String, dynamic> json) {
		return _$SystemConfigFromJson(json);
	}

	Map<String, dynamic> toJson() => _$SystemConfigToJson(this);
}
