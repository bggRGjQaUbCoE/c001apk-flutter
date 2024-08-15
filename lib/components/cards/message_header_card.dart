import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/global_data.dart';
import '../../utils/storage_util.dart';

class MessageHeaderCard extends StatelessWidget {
  const MessageHeaderCard({
    super.key,
    required this.onLogin,
    required this.onLogout,
  });

  final Function() onLogin;
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          if (!GlobalData().isLogin)
            FilledButton.tonal(
              onPressed: onLogin,
              child: const Text('点击登录'),
            ),
          Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: GlobalData().isLogin,
            child: Row(
              children: [
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => Get.toNamed('/u/${GlobalData().uid}'),
                  child: CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(GStorage.userAvatar),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 75,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        () {
                          String username = GlobalData().username;
                          try {
                            username = Uri.decodeComponent(username);
                          } catch (e) {
                            debugPrint(e.toString());
                          }
                          return username;
                        }(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Lv.${GStorage.level}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            '${GStorage.exp}/${GStorage.nextExp}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: GStorage.exp / GStorage.nextExp,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(flex: 25, child: SizedBox()),
                IconButton(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
