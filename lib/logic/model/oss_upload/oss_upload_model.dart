class OssUploadModel {
  String name;
  String resolution;
  String md5;

  OssUploadModel({
    required this.name,
    required this.resolution,
    required this.md5,
  });

  factory OssUploadModel.fromJson(Map<String, dynamic> json) {
    return OssUploadModel(
      name: json['name'] as String,
      resolution: json['resolution'] as String,
      md5: json['md5'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'resolution': resolution,
      'md5': md5,
    };
  }
}
