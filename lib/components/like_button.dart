import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.value,
    this.icon,
    this.like,
    this.onClick,
  });

  final dynamic value;
  final dynamic like;
  final IconData? icon;
  final Function()? onClick;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onClick,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        visualDensity: const VisualDensity(
          horizontal: -4,
          vertical: -4,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            like == 1
                ? Icons.thumb_up
                : like == 0
                    ? Icons.thumb_up_outlined
                    : icon,
            color: like == 1
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            size: MediaQuery.textScalerOf(context).scale(14),
          ),
          const SizedBox(width: 2),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: like == 1
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
