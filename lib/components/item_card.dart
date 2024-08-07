import 'package:c001apk_flutter/components/cards/like_card.dart';
import 'package:c001apk_flutter/components/cards/message_card.dart';
import 'package:c001apk_flutter/components/cards/notification_card.dart';
import 'package:flutter/material.dart';

import '../../components/cards/app_card.dart';
import '../../components/cards/carousel_card.dart';
import '../../components/cards/feed_card.dart';
import '../../components/cards/feed_reply_card.dart';
import '../../components/cards/icon_link_grid_card.dart';
import '../../components/cards/icon_mini_grid_card.dart';
import '../../components/cards/icon_mini_scroll_card.dart';
import '../../components/cards/icon_scroll_card.dart';
import '../../components/cards/image_square_scroll_card.dart';
import '../../components/cards/image_text_scroll_card.dart';
import '../../components/cards/title_card.dart';
import '../../logic/model/feed/datum.dart';
import '../../utils/extensions.dart';

Widget itemCard(
  Datum data, {
  bool isFeedContent = false,
  bool isHomeCard = false,
  bool isReply2Reply = false,
  bool isTopReply = false,
  dynamic uid,
}) {
  switch (data.entityType) {
    case 'card':
      switch (data.entityTemplate) {
        case 'imageCarouselCard_1':
          return CarouselCard(dataList: data.entities!);
        case 'iconLinkGridCard':
          return IconLinkGridCard(dataList: data.entities!);
        case 'iconMiniScrollCard':
          return IconMiniScrollCard(dataList: data.entities!);
        case 'iconMiniGridCard':
          return IconMiniGridCard(data: data);
        case 'imageSquareScrollCard':
          return ImageSquareScrollCard(dataList: data.entities!);
        case 'titleCard':
          return TitleCard(title: data.title.orEmpty, url: data.url.orEmpty);
        case 'iconScrollCard':
          return IconScrollCard(data: data);
        case 'imageTextScrollCard':
          return ImageTextScrollCard(data: data);
      }
    case 'feed':
      return FeedCard(data: data, isFeedContent: isFeedContent);
    case 'feed_reply':
      if (data.likeUserInfo != null) {
        return LikeCard(data: data);
      } else {
        return FeedReplyCard(
          data: data,
          isReply2Reply: isReply2Reply,
          isTopReply: isTopReply,
          uid: uid,
        );
      }
    case 'apk':
      return AppCard(
        appCardType: AppCardType.APP,
        data: data,
        isHomeCard: isHomeCard,
      );
    case 'product':
      return AppCard(
        appCardType: AppCardType.PRODUCT,
        data: data,
        isHomeCard: isHomeCard,
      );
    case 'user':
      return AppCard(
        appCardType: AppCardType.USER,
        data: data,
        isHomeCard: isHomeCard,
      );
    case 'topic':
      return AppCard(
        appCardType: AppCardType.TOPIC,
        data: data,
        isHomeCard: isHomeCard,
      );
    case 'contacts':
      return AppCard(
        appCardType: AppCardType.CONTACTS,
        data: data,
        isHomeCard: isHomeCard,
      );
    case 'recentHistory':
      return AppCard(
        appCardType: AppCardType.RECENT,
        data: data,
        isHomeCard: isHomeCard,
      );
    case 'notification':
      return NotificationCard(data: data);
    case 'message':
      return MessageCard(data: data);
    case 'collection':
      return const ListTile(title: Text('collection'));
  }
  return ListTile(
    title: Text(data.entityType.toString()),
    subtitle: Text(data.entityTemplate.toString()),
  );
}
