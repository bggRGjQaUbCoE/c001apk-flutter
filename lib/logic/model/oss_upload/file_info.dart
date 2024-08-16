class FileInfo {
  String? name;
  String? resolution;
  String? md5;
  String? url;
  String? uploadFileName;

  FileInfo({
    this.name,
    this.resolution,
    this.md5,
    this.url,
    this.uploadFileName,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      name: json['name'] as String?,
      resolution: json['resolution'] as String?,
      md5: json['md5'] as String?,
      url: json['url'] as String?,
      uploadFileName: json['uploadFileName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'resolution': resolution,
      'md5': md5,
      'url': url,
      'uploadFileName': uploadFileName,
    };
  }
}
