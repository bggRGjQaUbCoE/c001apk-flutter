import 'package:flutter/material.dart';

class TextCard extends StatelessWidget {
  const TextCard({
    super.key,
    required this.text,
    this.isMessage = false,
    this.isEndCard = false,
    this.isRefreshCard = false,
  });

  final String text;
  final bool isMessage;
  final bool isEndCard;
  final bool isRefreshCard;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: isEndCard ? 80 : null,
      alignment: isEndCard ? Alignment.center : null,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMessage
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: isRefreshCard || isEndCard ? TextAlign.center : null,
        style: TextStyle(
          color: isMessage
              ? Theme.of(context).colorScheme.onSecondaryContainer
              : Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
