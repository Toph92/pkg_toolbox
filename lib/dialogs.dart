import 'dart:ui';

import 'package:flutter/material.dart';

class DialogBuilder<T> {
  final GlobalKey<State<AlertDialogCust>>? key;
  final BuildContext context;

  /// String or Widget type message
  final dynamic message;
  final dynamic altMessage;
  List<DialogButton> actionButtons = [];
  DialogType type = DialogType.none;
  bool shuffleButtons;
  bool withBackgroundColor;
  bool blurBackground;
  bool? dimissible;
  Icon? icon;

  //

  /// An object that can be used to identify this dialog.
  String? tag;

  DialogBuilder({
    required this.context,
    required this.message,
    this.altMessage,
    this.key,
    this.tag,
    this.shuffleButtons = false,
    this.withBackgroundColor = false,
    this.blurBackground = false,
    this.dimissible,
    this.icon,
  }) {
    assert(message is String || message is Widget);
    assert(altMessage is String || altMessage is Widget || altMessage == null);
    if (tag?.trim() == '') tag = null;
  }

  Future<T?> _showAlertDialog() async {
    T? result;

    dimissible ??= type.dimissible;
    dimissible ??= false;

    if (tag != null && checked.containsKey(tag)) return null;
    await showGeneralDialog(
      barrierColor:
          dimissible == false && withBackgroundColor && type.color != null
          ? type.color!.withAlpha((0.5 * 255).toInt())
          : dimissible == true && withBackgroundColor && type.color != null
          ? type.color!.withAlpha((0.1 * 255).toInt())
          : Colors.black.withAlpha((0.5 * 255).toInt()),
      barrierDismissible: dimissible!,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      context: context,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder:
          (
            BuildContext context,
            Animation animation,
            Animation secondaryAnimation,
          ) {
            return Container();
          },
      transitionBuilder: (ctx, a1, a2, child) {
        var curve = Curves.easeInOut.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: type.dimissible == true && blurBackground == false
                  ? 0
                  : 3,
              sigmaY: type.dimissible == true && blurBackground == false
                  ? 0
                  : 3,
            ),
            child: NotificationListener(
              onNotification: (notification) {
                if (notification is DialogNotification) {
                  result = notification.value as T;
                }
                return false;
              },
              child: AlertDialogCust(
                context: context,
                message: message,
                altMessage: altMessage,
                tag: tag,
                actionButtons: actionButtons,
                type: type,
                icon: icon,
                shuffleButtons: shuffleButtons,
              ),
            ),
          ),
        );
      },
    );
    return result;
  }

  Future<T?> ok() async {
    actionButtons = [DialogButton(label: "OK", value: true)];
    type = DialogType.info;
    dimissible ??= true;
    withBackgroundColor = true;
    return _showAlertDialog();
  }

  Future<T?> error() async {
    actionButtons = [DialogButton(label: "OK", value: true)];
    type = DialogType.error;
    withBackgroundColor = true;
    return _showAlertDialog();
  }

  Future<T?> warning() async {
    actionButtons = [DialogButton(label: "OK", value: true)];
    type = DialogType.warning;
    withBackgroundColor = true;
    return _showAlertDialog();
  }

  Future<T?> yesNo({String yesLabel = 'Oui', String noLabel = 'Non'}) async {
    actionButtons = [
      DialogButton(label: yesLabel, value: true),
      DialogButton(label: noLabel, value: false),
    ];
    assert(message is String && message.endsWith('?') == true);
    type = DialogType.question;
    withBackgroundColor = true;
    return _showAlertDialog();
  }

  Future<T?> removeCancel({
    String yesLabel = 'Supprimer',
    String noLabel = 'Annuler',
  }) async {
    actionButtons = [
      DialogButton(label: noLabel, value: false),
      DialogButton(label: yesLabel, value: true),
    ];
    assert(message is String && message.endsWith('?') == true);
    type = DialogType.remove;
    return _showAlertDialog();
  }

  Future<T?> custom({
    DialogType type = DialogType.none,
    required List<DialogButton> dialogButtons,
  }) async {
    actionButtons = dialogButtons;
    this.type = type;
    return _showAlertDialog();
  }
}

class AlertDialogCust extends StatefulWidget {
  const AlertDialogCust({
    super.key,
    required this.context,
    required this.message,
    this.altMessage,
    required this.actionButtons,
    required this.type,
    required this.shuffleButtons,
    this.tag,
    this.icon,
  });
  final BuildContext context;

  /// String or Widget type message
  final dynamic message;
  final dynamic altMessage;
  final String? tag;
  final DialogType type;
  final bool shuffleButtons;
  final List<DialogButton> actionButtons;
  final Icon? icon;

  @override
  State<AlertDialogCust> createState() => _AlertDialogCustState();
}

class _AlertDialogCustState extends State<AlertDialogCust> {
  bool checkboxValueCity = false;
  late List<DialogButton> actionButtons;

  @override
  void initState() {
    actionButtons = widget.actionButtons;
    widget.shuffleButtons ? widget.actionButtons.shuffle() : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 10,
          shadowColor: Colors.black,
          content: Row(
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 4),
              ] else if (widget.type.iconData != null &&
                  widget.type.size != null) ...[
                Icon(
                  widget.type.iconData!,
                  size: widget.type.size,
                  color: widget.type.color,
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (widget.message) is String
                          ? Text(
                              widget.message,
                              softWrap: true,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : widget.message,
                      widget.altMessage is String
                          ? Text(
                              widget.altMessage,
                              softWrap: true,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          : widget.altMessage ?? const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (widget.tag != null)
              FittedBox(
                child: Tooltip(
                  message: "Ne plus afficher cette notification",
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          "Ne plus afficher",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: checked[widget.tag] ?? false,
                        onChanged: (bool? value) {
                          assert(widget.tag != null && widget.tag != '');
                          checked[widget.tag!] = value!;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            FittedBox(
              child: Row(
                children: actionButtons
                    .map<Widget>(
                      (e) => TextButton(
                        onPressed: () {
                          DialogNotification(e.value).dispatch(context);
                          Navigator.of(context).pop(e.value);
                        },
                        child: Text(
                          e.label,
                          style: e.isDefault == true
                              ? const TextStyle(fontWeight: FontWeight.bold)
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DialogNotification extends Notification {
  final dynamic value;
  DialogNotification(this.value);
}

Map<String, bool> checked = {};

class DialogButton {
  final String label;
  final dynamic value;
  final bool isDefault;
  DialogButton({
    required this.label,
    required this.value,
    this.isDefault = false,
  });
}

enum DialogType {
  info(
    color: Colors.blue,
    iconData: Icons.info_outline_rounded,
    size: 50,
    dimissible: null,
  ),
  error(
    color: Colors.red,
    iconData: Icons.error_outline_rounded,
    size: 50,
    dimissible: false,
  ),
  warning(
    color: Colors.orange,
    iconData: Icons.warning_amber_rounded,
    size: 50,
    dimissible: false,
  ),
  remove(
    color: Colors.red,
    iconData: Icons.delete,
    size: 50,
    dimissible: false,
  ),
  question(
    color: Colors.green,
    iconData: Icons.help,
    size: 50,
    dimissible: false,
  ),
  none();

  final IconData? iconData;
  final Color? color;
  final double? size;
  final bool? dimissible;

  const DialogType({this.iconData, this.color, this.size, this.dimissible});
}
