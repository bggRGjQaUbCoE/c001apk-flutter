import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.value,
    required this.icon,
    this.isLike = false,
    this.onClick,
  });

  final dynamic value;
  final IconData icon;
  final bool isLike;
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
            icon,
            color: isLike
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
              color: isLike
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
