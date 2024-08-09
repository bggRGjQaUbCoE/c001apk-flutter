import 'package:flutter/material.dart';

class SearchHistoryCard extends StatelessWidget {
  const SearchHistoryCard({
    super.key,
    required this.text,
    required this.onTap,
    required this.onLongPress,
  });

  final String text;
  final Function() onTap;
  final Function() onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(height: 1),
          strutStyle: const StrutStyle(leading: 0, height: 1),
        ),
      ),
    );
  }
}
