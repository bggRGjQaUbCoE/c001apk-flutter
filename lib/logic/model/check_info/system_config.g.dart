// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemConfig _$SystemConfigFromJson(Map<String, dynamic> json) => SystemConfig(
      systemConfig: json['system_config'] as String?,
      spamWordConfig: json['spam_word_config'] as String?,
    );

Map<String, dynamic> _$SystemConfigToJson(SystemConfig instance) =>
    <String, dynamic>{
      'system_config': instance.systemConfig,
      'spam_word_config': instance.spamWordConfig,
    };
