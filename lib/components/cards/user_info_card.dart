import 'dart:math';

import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../logic/model/feed/datum.dart';
import '../../pages/ffflist/ffflist_page.dart';
import '../../utils/date_util.dart';
import '../../utils/global_data.dart';
import '../../utils/storage_util.dart';
import '../../utils/utils.dart';

class UserInfoCard extends StatelessWidget {
  const UserInfoCard({
    super.key,
    required this.data,
    required this.onFollow,
  });

  final Datum data;
  final Function(dynamic uid, dynamic isFollow) onFollow;

  @override
  Widget build(BuildContext context) {
    bool darken = GStorage.getBrightness() == Brightness.light;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Map<dynamic, dynamic> arguments = {
                      "imgList": [data.cover.toString()],
                    };
                    Get.toNamed('/imageview', arguments: arguments);
                  },
                  child: networkImage(
                    data.cover.toString(),
                    width: double.infinity,
                    height: 125,
                    borderRadius: null,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            darken
                                ? const Color(0x8D000000)
                                : const Color(0x5DFFFFFF),
                            darken ? BlendMode.darken : BlendMode.lighten,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: double.infinity, height: 40)
              ],
            ),
            Positioned(
              top: 85,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  Map<dynamic, dynamic> arguments = {
                    "imgList": [data.userAvatar.toString()],
                  };
                  Get.toNamed('/imageview', arguments: arguments);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 4,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: clipNetworkImage(
                    data.userAvatar ?? '',
                    isAvatar: true,
                    width: 76,
                    height: 76,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 128,
              right: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.outlined(
                    onPressed: () {
                      if (GlobalData().isLogin) {
                        int uid = data.uid;
                        int mUid = int.parse(GlobalData().uid);
                        String ukey = '${min(uid, mUid)}_${max(uid, mUid)}';
                        Get.toNamed('/chat', parameters: {
                          'ukey': ukey,
                          'uid': data.uid.toString(),
                          'username': data.username ?? '',
                        });
                      }
                    },
                    icon: const Icon(Icons.mail_outline, size: 21),
                    style: IconButton.styleFrom(
                      side: BorderSide(
                        width: 1.0,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.5),
                      ),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(
                        horizontal: -2,
                        vertical: -2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.tonal(
                    onPressed: () {
                      if (GlobalData().isLogin) {
                        onFollow(data.uid, data.isFollow);
                      }
                    },
                    style: FilledButton.styleFrom(
                      visualDensity: const VisualDensity(
                        horizontal: -2,
                        vertical: -2,
                      ),
                    ),
                    child: Text(data.isFollow == 1 ? '取消关注' : '关注'),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () =>
                Utils.copyText(data.userInfo?.username ?? data.username ?? ''),
            child: Text(
              data.userInfo?.username ?? data.username ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 4, right: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Utils.copyText(data.uid.toString()),
                child: Text(
                  'uid: ${data.uid.toString()}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Text(
                  'Lv.${data.level}',
                  style: TextStyle(
                    height: 1,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  strutStyle: const StrutStyle(
                    height: 1,
                    leading: 0,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 4, right: 20),
          child: Row(
            children: [
              Text(
                '${data.feed.toString()}动态',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 10),
              Text(
                '${data.beLikeNum.toString()}赞',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Get.toNamed(
                  '/ffflist',
                  arguments: {
                    'type': FFFListType.USER_FOLLOW,
                    'uid': data.uid.toString(),
                  },
                ),
                child: Text(
                  '${data.follow.toString()}关注',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Get.toNamed(
                  '/ffflist',
                  arguments: {
                    'type': FFFListType.FAN,
                    'uid': data.uid.toString(),
                  },
                ),
                child: Text(
                  '${data.fans.toString()}粉丝',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 4, right: 20),
          child: Text(
            '${DateUtil.fromToday(data.logintime)}活跃',
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
