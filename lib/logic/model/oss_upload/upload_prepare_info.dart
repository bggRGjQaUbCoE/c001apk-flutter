class UploadPrepareInfo {
  String? accessKeySecret;
  String? accessKeyId;
  String? securityToken;
  String? expiration;
  String? uploadImagePrefix;
  String? endPoint;
  String? bucket;
  String? callbackUrl;

  UploadPrepareInfo({
    this.accessKeySecret,
    this.accessKeyId,
    this.securityToken,
    this.expiration,
    this.uploadImagePrefix,
    this.endPoint,
    this.bucket,
    this.callbackUrl,
  });

  factory UploadPrepareInfo.fromJson(Map<String, dynamic> json) {
    return UploadPrepareInfo(
      accessKeySecret: json['accessKeySecret'] as String?,
      accessKeyId: json['accessKeyId'] as String?,
      securityToken: json['securityToken'] as String?,
      expiration: json['expiration'] as String?,
      uploadImagePrefix: json['uploadImagePrefix'] as String?,
      endPoint: json['endPoint'] as String?,
      bucket: json['bucket'] as String?,
      callbackUrl: json['callbackUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessKeySecret': accessKeySecret,
      'accessKeyId': accessKeyId,
      'securityToken': securityToken,
      'expiration': expiration,
      'uploadImagePrefix': uploadImagePrefix,
      'endPoint': endPoint,
      'bucket': bucket,
      'callbackUrl': callbackUrl,
    };
  }
}
