import 'package:flutter/material.dart';

class ToolbarIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final bool selected;

  const ToolbarIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.selected,
  });

  @override
  State<StatefulWidget> createState() => ToolbarIconButtonState();
}

class ToolbarIconButtonState extends State<ToolbarIconButton> {
  late bool selected = widget.selected;

  void updateSelected(bool selected) {
    setState(() => this.selected = selected);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: widget.onPressed,
        icon: widget.icon,
        highlightColor: Theme.of(context).colorScheme.secondaryContainer,
        color: selected
            ? Theme.of(context).colorScheme.onSecondaryContainer
            : Theme.of(context).colorScheme.outline,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return selected
                ? Theme.of(context).colorScheme.secondaryContainer
                : null;
          }),
        ),
      ),
    );
  }
}
