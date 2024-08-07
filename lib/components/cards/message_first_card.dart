import 'package:flutter/material.dart';

Widget messageFirstCard(
  BuildContext context,
  List<int?>? values,
) {
  return Material(
    clipBehavior: Clip.hardEdge,
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    color: Theme.of(context).colorScheme.onInverseSurface,
    child: messageFirstCardRow(context, values, ['动态', '关注', '粉丝']),
  );
}

Widget messageFirstCardRow(
  BuildContext context,
  List<int?>? values,
  List<String> titles, [
  List<IconData>? icons,
]) {
  return IntrinsicHeight(
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child:
              _messageFirstCardItem(context, values?[0], titles[0], icons?[0]),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: VerticalDivider(width: 1),
        ),
        Expanded(
          flex: 1,
          child:
              _messageFirstCardItem(context, values?[1], titles[1], icons?[1]),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: VerticalDivider(width: 1),
        ),
        Expanded(
          flex: 1,
          child:
              _messageFirstCardItem(context, values?[2], titles[2], icons?[2]),
        ),
      ],
    ),
  );
}

Widget _messageFirstCardItem(
  BuildContext context,
  int? value,
  String title, [
  IconData? icon,
]) {
  return InkWell(
    onTap: () {},
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: icon != null ? true : value != null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            if (icon == null)
              Text(
                value.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'sans-serif',
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
