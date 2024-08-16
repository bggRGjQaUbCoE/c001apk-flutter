/// 上传配置信息AliyunOssInfo
///
/// bucket: 阿里云Bucket，鉴权后获取相应的值
/// endpoint: 阿里云Endpoint，鉴权后获取相应的值
/// accessKeyId: 阿里云AccessKeyId，鉴权后获取相应的值
/// accessKeySecret 阿里云AccessKeySecret，鉴权后获取相应的值
/// securityToken 阿里云SecurityToken，鉴权后获取相应的值
/// domain: 访问文件时的域名。如果不填写默认为 https://$bucket.$endpoint
/// directory: 上传文件的目录，如果不填写默认为根目录
/// objectPath: 阿里云服务器文件路径 domain(https://$bucket.$endpoint) + directory + ossFileName
/// contentType: 文件类型. 常见的有: image/png image/jpeg audio/mp3 video/mp4 阿里云支持的上传文件类型 https://help.aliyun.com/document_detail/39522.html
class AliyunOssConfig {
  late String bucket;
  late String endpoint;
  late String directory;
  String? domain;

  AliyunOssConfig({
    required String? endpoint,
    required String? bucket,
    required String? directory,
    String? domain,
  }) {
    assert(endpoint != null && bucket != null && directory != null);

    String ossEndpoint = endpoint?.replaceFirst("https://", "") ?? "";
    ossEndpoint = ossEndpoint.replaceFirst("http://", "");
    this.endpoint = ossEndpoint;
    this.bucket = bucket ?? "";
    this.domain = domain ?? "https://$bucket.$ossEndpoint";
    this.directory = directory ?? "";
  }
}

enum AliyunOssResultState { none, success, fail, uploading }

class AliyunOssResult {
  String id;
  AliyunOssResultState state;
  String? url;
  String? msg;
  int? count;
  int? total;
  AliyunOssResult({
    required this.id,
    this.state = AliyunOssResultState.none,
    this.url,
    this.msg,
    this.count,
    this.total,
  });
  @override
  String toString() {
    return 'AliyunOssResult{id: $id, state: $state, url: $url, msg: $msg, count: $count, total: $total}';
  }
}
