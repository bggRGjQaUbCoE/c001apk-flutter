import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/storage_util.dart';

class DropDownMenuItem extends StatefulWidget {
  const DropDownMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.boxKey,
    required this.items,
    this.forceAppUpdate = false,
  });

  final IconData icon;
  final String title;
  final String boxKey;
  final List<DropdownMenuItem<int>> items;
  final bool forceAppUpdate;

  @override
  State<DropDownMenuItem> createState() => _DropDownMenuItemState();
}

class _DropDownMenuItemState extends State<DropDownMenuItem> {
  late int value;

  @override
  void initState() {
    super.initState();
    value = GStorage.settings.get(widget.boxKey, defaultValue: 0);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget.icon),
      title: Text(widget.title),
      trailing: DropdownButton<int>(
        value: value,
        onChanged: (int? newValue) {
          if (newValue != null) {
            GStorage.settings.put(widget.boxKey, newValue);
            setState(() => value = newValue);
            if (widget.forceAppUpdate) {
              Get.forceAppUpdate();
            }
          }
        },
        items: widget.items,
      ),
    );
  }
}
