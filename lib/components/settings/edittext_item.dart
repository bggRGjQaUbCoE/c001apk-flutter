import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/dialog.dart';
import '../../utils/storage_util.dart';

class EdittextItem extends StatefulWidget {
  const EdittextItem({
    super.key,
    this.icon,
    required this.title,
    required this.boxKey,
    this.needUpdateUserAgent = false,
    this.needUpdateXAppDevice = false,
    this.forceAppUpdate = false,
    this.onChanged,
  });

  final IconData? icon;
  final String title;
  final String boxKey;
  final bool needUpdateUserAgent;
  final bool needUpdateXAppDevice;
  final bool forceAppUpdate;
  final Function()? onChanged;

  @override
  State<EdittextItem> createState() => EdittextItemState();
}

class EdittextItemState extends State<EdittextItem> {
  late String value;

  @override
  void initState() {
    super.initState();
    getValue();
  }

  void updateValue() {
    setState(() => getValue());
  }

  void getValue() {
    value = GStorage.settings.get(widget.boxKey, defaultValue: '');
  }

  void onChanged(String value) async {
    await GStorage.settings.put(widget.boxKey, value);
    if (widget.needUpdateUserAgent) {
      GStorage.fullSetUserAgent();
    }
    if (widget.needUpdateXAppDevice) {
      await GStorage.fullSetXAppDevice();
    }
    if (widget.onChanged != null) {
      widget.onChanged!();
    } else {
      setState(() => this.value = value);
    }
    if (widget.forceAppUpdate) {
      Get.forceAppUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.icon != null ? Icon(widget.icon) : null,
      title: Text(widget.title),
      subtitle: value.isNotEmpty ? Text(value) : null,
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) {
          return EditTextDialog(
            title: widget.title,
            defaultText: value,
            setData: onChanged,
          );
        },
      ),
    );
  }
}
