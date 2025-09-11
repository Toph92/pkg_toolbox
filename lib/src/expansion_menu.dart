import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Widget générique réutilisable pour une section du menu.
class MenuExpansionSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isExpanded;
  final ExpansibleController controller;
  final ValueChanged<bool> onExpansionChanged;
  final Widget content;
  final Color headerExpandedBackgroundColor;
  final Color collapsedBackgroundColor;
  final Color headerExpandedForegroundColor;
  final Color contentBackgroundColor;
  final EdgeInsetsGeometry contentPadding;
  final bool enabled;
  final Color? disabledColor;

  const MenuExpansionSection({
    super.key,
    required this.title,
    required this.icon,
    required this.isExpanded,
    required this.controller,
    required this.onExpansionChanged,
    required this.content,
    this.headerExpandedBackgroundColor = Colors.black,
    this.collapsedBackgroundColor = const Color.fromARGB(
      255,
      224,
      224,
      224,
    ), // gris
    this.headerExpandedForegroundColor = Colors.blue,
    this.contentBackgroundColor = Colors.white,
    this.contentPadding = const EdgeInsets.only(left: 4),
    this.enabled = true,
    this.disabledColor,
  });

  @override
  State<MenuExpansionSection> createState() => _MenuExpansionSectionState();
}

class _MenuExpansionSectionState extends State<MenuExpansionSection> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final disabledColor = widget.disabledColor ?? Colors.grey.shade500;
    // Couleur d'arrière plan calculée (collapsed / hover / expanded)
    final bool expanded = widget.isExpanded;
    final Color collapsedBase = widget.collapsedBackgroundColor;
    final Color hoverColor = Colors.yellow.withValues(alpha: 0.7);
    final Color bg = !widget.enabled
        ? collapsedBase.withValues(alpha: 0.3)
        : expanded
        ? widget.headerExpandedBackgroundColor
        : (_isHovered ? hoverColor : collapsedBase);

    final tile = Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent, // retire la ligne de séparation
      ),
      child: ExpansionTile(
        controller: widget.controller,
        onExpansionChanged: widget.enabled ? widget.onExpansionChanged : (_) {},
        backgroundColor: widget.headerExpandedBackgroundColor,
        collapsedBackgroundColor: Colors.transparent,
        tilePadding: EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.zero,
        leading: Icon(
          widget.icon,
          color: !widget.enabled
              ? disabledColor
              : (expanded
                    ? widget.headerExpandedForegroundColor
                    : Colors.blueGrey.shade700),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: widget.enabled && expanded
                ? FontWeight.bold
                : FontWeight.normal,
            color: !widget.enabled
                ? disabledColor
                : (expanded
                      ? widget.headerExpandedForegroundColor
                      : Colors.blue),
          ),
        ),
        children: widget.enabled
            ? [
                Container(
                  width: double.infinity,
                  padding: widget.contentPadding,
                  color: widget.contentBackgroundColor,
                  child: widget.content,
                ),
              ]
            : const [],
      ),
    );

    final decorated = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      color: bg,
      child: tile,
    );

    final effectiveTile = widget.enabled
        ? decorated
        : IgnorePointer(
            ignoring: true,
            child: Opacity(opacity: 0.6, child: decorated),
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: effectiveTile,
    );
  }
}

class ItemController {
  final String label;
  bool expanded;
  bool enabled;
  bool visible;
  String title;
  final IconData? icon;
  final ExpansibleController expansionController = ExpansibleController();
  Widget content;

  ItemController({
    required this.label,
    required this.title,
    required this.content,
    this.icon,
    this.expanded = false,
    this.enabled = true,
    this.visible = true,
  });

  void expand() => expanded = true;
  void collapse() => expanded = false;
}

// Contrôleur externe pour conserver l'état du menu entre plusieurs instances
// de MenuWidget (ex: drawer vs panneau latéral).
class AppMenuController {
  final Map<String, ItemController> menuEntries;

  AppMenuController(this.menuEntries);

  void expandAll() {
    for (final entry in menuEntries.values) {
      if (entry.visible && entry.enabled) {
        entry.expand();
        entry.expansionController.expand();
      }
    }
  }

  void collapseAll() {
    for (final entry in menuEntries.values) {
      if (entry.visible && entry.enabled) {
        entry.collapse();
        entry.expansionController.collapse();
      }
    }
  }
}

mixin MenuWidgetMixin<T extends StatefulWidget> on State<T> {
  late final AppMenuController menuController;

  Map<String, ItemController> get items => menuController.menuEntries;

  void _refresh() {
    if (mounted) setState(() {});
  }

  void collapseAll() {
    menuController.collapseAll();
    _refresh();
  }

  void expandAll() {
    menuController.expandAll();
    _refresh();
  }

  Widget buildSection(ItemController item /*  {Widget? content} */) {
    if (!item.visible) return const SizedBox.shrink();
    return MenuExpansionSection(
      title: item.title,
      icon: item.icon ?? Icons.menu,
      isExpanded: item.expanded,
      controller: item.expansionController,
      enabled: item.enabled,
      onExpansionChanged: (expanded) {
        if (!item.enabled) return;
        setState(() => item.expanded = expanded);
      },
      content: /* content ??  */ item.content,
    );
  }
}

//*********************************************************************** */
