import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../logic/model/oss_upload/datum.dart';
import '../logic/model/oss_upload/oss_upload_model.dart';
import '../logic/model/oss_upload/oss_upload_response.dart';
import '../logic/network/network_repo.dart';
import '../utils/extensions.dart';

class OssUtil {
  static Future<OssDatum?> onPostOSSUploadPrepare(
    String uploadBucket,
    String uploadDir,
    List<OssUploadModel> dataList, {
    String? uid,
  }) async {
    try {
      SmartDialog.showLoading(msg: '准备上传图片');
      Response response = await NetworkRepo.postOSSUploadPrepare(
        data: FormData.fromMap(
          {
            'uploadBucket': uploadBucket,
            'uploadDir': uploadDir,
            'is_anonymous': '0',
            'uploadFileList': dataList
                .map((data) => jsonEncode(data.toJson()))
                .toList()
                .toString(),
            'toUid': uid,
          },
        ),
      );
      OssUploadResponse data = OssUploadResponse.fromJson(response.data);
      if (!data.message.isNullOrEmpty) {
        SmartDialog.dismiss();
        SmartDialog.showToast(data.message!);
        return null;
      } else if (data.data != null) {
        // SmartDialog.dismiss();
        return data.data!;
      }
      return null;
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast(e.toString());
      return null;
    }
  }
}
