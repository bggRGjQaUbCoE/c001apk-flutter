import 'file_info.dart';
import 'upload_prepare_info.dart';

class OssDatum {
  List<FileInfo>? fileInfo;
  UploadPrepareInfo? uploadPrepareInfo;

  OssDatum({
    this.fileInfo,
    this.uploadPrepareInfo,
  });

  factory OssDatum.fromJson(Map<String, dynamic> json) {
    return OssDatum(
      fileInfo: (json['fileInfo'] as List<dynamic>?)
          ?.map((e) => FileInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      uploadPrepareInfo: json['uploadPrepareInfo'] == null
          ? null
          : UploadPrepareInfo.fromJson(
              json['uploadPrepareInfo'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileInfo': fileInfo,
      'uploadPrepareInfo': uploadPrepareInfo,
    };
  }
}
