import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/storage_util.dart';

class SwitchItem extends StatefulWidget {
  const SwitchItem({
    super.key,
    required this.icon,
    required this.title,
    required this.boxKey,
    required this.defaultValue,
    this.forceAppUpdate = false,
  });

  final IconData icon;
  final String title;
  final String boxKey;
  final bool defaultValue;
  final bool forceAppUpdate;

  @override
  State<SwitchItem> createState() => _SwitchItemState();
}

class _SwitchItemState extends State<SwitchItem> {
  late bool value;

  @override
  void initState() {
    super.initState();
    value =
        GStorage.settings.get(widget.boxKey, defaultValue: widget.defaultValue);
  }

  void onChanged(bool value) async {
    await GStorage.settings.put(widget.boxKey, value);
    if (widget.forceAppUpdate) {
      Get.forceAppUpdate();
    }
    setState(() => this.value = value);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget.icon),
      title: Text(widget.title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      onTap: () => onChanged(!value),
    );
  }
}
