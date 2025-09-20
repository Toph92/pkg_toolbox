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
  final Widget? header;
  final Color headerExpandedBackgroundColor;
  final Color collapsedBackgroundColor;
  final Color headerExpandedForegroundColor;
  final Color contentBackgroundColor;
  //final EdgeInsetsGeometry contentPadding;
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
    //this.contentPadding = const EdgeInsets.only(left: 4),
    this.enabled = true,
    this.disabledColor,
    this.header,
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
        title: () {
          final textStyle = TextStyle(
            fontWeight: widget.enabled && expanded
                ? FontWeight.bold
                : FontWeight.normal,
            color: !widget.enabled
                ? disabledColor
                : (expanded
                      ? widget.headerExpandedForegroundColor
                      : Colors.blue),
          );

          return widget.header != null
              ? Row(
                  children: [
                    Text(widget.title, style: textStyle),
                    const SizedBox(width: 8),
                    widget.header!,
                  ],
                )
              : Text(widget.title, style: textStyle);
        }(),
        children: widget.enabled
            ? [
                Container(
                  width: double.infinity,
                  //padding: widget.contentPadding,
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

/// Type d'entrée du menu :
/// - header : widget fixe en haut, non scrollé, non extensible
/// - section : section extensible
enum MenuType { header, section }

class ItemController {
  MenuType type;
  final String label;
  bool expanded;
  bool enabled;
  bool visible;
  String title;
  final IconData? icon;
  final ExpansibleController expansionController = ExpansibleController();
  Widget content;
  Widget? header;

  ItemController({
    required this.type,
    required this.label,
    required this.title,
    required this.content,
    this.icon,
    this.expanded = false,
    this.enabled = true,
    this.visible = true,
    this.header,
  });

  void expand() => expanded = true;
  void collapse() => expanded = false;

  bool get isHeader => type == MenuType.header;
  bool get isSection => type == MenuType.section;
}

// Contrôleur externe pour conserver l'état du menu entre plusieurs instances
// de MenuWidget (ex: drawer vs panneau latéral).
class AppMenuController extends ChangeNotifier {
  final Map<String, ItemController> menuEntries = {};
  // Mémorise l'état d'expansion précédent lors d'un hide()
  final Map<String, bool> _rememberedExpanded = {};

  AppMenuController();

  void register(ItemController item) {
    menuEntries[item.label] = item;
    // Synchronise l'état visuel initial si marqué expanded
    if (item.expanded && item.isSection) {
      item.expansionController.expand();
    }
    notifyListeners();
  }

  void registerAll(Iterable<ItemController> items) {
    for (final i in items) {
      menuEntries[i.label] = i;
      if (i.expanded && i.isSection) {
        i.expansionController.expand();
      }
    }
    notifyListeners();
  }

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

  /// Bascule (expand/collapse) une section par son label.
  /// - Met à jour le booléen [expanded]
  /// - Appelle le controller d'expansion pour refléter visuellement
  /// - Notifie les listeners
  void switchExpansion(String label) {
    final entry = menuEntries[label];
    if (entry == null) return; // label inconnu
    if (!entry.visible || !entry.enabled || entry.isHeader) {
      return; // rien à faire
    }

    entry.expanded = !entry.expanded;
    if (entry.expanded) {
      entry.expansionController.expand();
    } else {
      entry.expansionController.collapse();
    }
    notifyListeners();
  }

  /// Force l'expansion d'une section (si possible)
  void expandOne(String label) {
    final entry = menuEntries[label];
    if (entry == null) return;
    if (!entry.visible || !entry.enabled || entry.isHeader) return;
    entry.expanded = true;
    entry.expansionController.expand();
    notifyListeners();
  }

  /// Force la réduction d'une section (si possible)
  void collapseOne(String label) {
    final entry = menuEntries[label];
    if (entry == null) return;
    if (!entry.visible || !entry.enabled || entry.isHeader) return;
    entry.expanded = false;
    entry.expansionController.collapse();
    notifyListeners();
  }

  /// Rend visible un item sans restauration d'état (interne)
  void showRaw(String label) {
    final entry = menuEntries[label];
    if (entry == null) return;
    if (entry.visible) return;
    entry.visible = true;
    notifyListeners();
  }

  /// Cache un item. Si c'est une section étendue elle est d'abord repliée.
  void hide(String label, {bool rememberState = true}) {
    final entry = menuEntries[label];
    if (entry == null) return;
    if (!entry.visible) return;
    if (rememberState && entry.isSection) {
      _rememberedExpanded[label] = entry.expanded;
    }
    if (entry.isSection && entry.expanded) {
      entry.expanded = false;
      entry.expansionController.collapse();
    }
    entry.visible = false;
    notifyListeners();
  }

  /// Rend visible un item et restaure éventuellement son état d'expansion précédent
  void show(String label, {bool restoreState = true}) {
    final entry = menuEntries[label];
    if (entry == null) return;
    if (entry.visible) return;
    entry.visible = true;
    if (restoreState && entry.isSection) {
      final wasExpanded = _rememberedExpanded[label];
      if (wasExpanded == true) {
        entry.expanded = true;
        entry.expansionController.expand();
      }
    }
    notifyListeners();
  }

  /// Bascule visibilité (restaure l'état d'expansion précédent si ré-affiché)
  void switchVisibility(String label) {
    final entry = menuEntries[label];
    if (entry == null) return;
    if (entry.visible) {
      hide(label, rememberState: true);
    } else {
      show(label, restoreState: true);
    }
  }

  /// Met à jour l'état d'expansion d'une section et notifie les listeners
  void updateExpandedState(String label, bool expanded) {
    final entry = menuEntries[label];
    if (entry == null) return;
    if (!entry.visible || !entry.enabled || entry.isHeader) return;
    entry.expanded = expanded;
    if (expanded) {
      entry.expansionController.expand();
    } else {
      entry.expansionController.collapse();
    }
    notifyListeners();
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
    if (item.isHeader) {
      // Un header est rendu tel quel, sans logique d'expansion.
      return item.content;
    }
    return MenuExpansionSection(
      title: item.title,
      header: item.header,
      icon: item.icon ?? Icons.menu,
      isExpanded: item.expanded,
      controller: item.expansionController,
      enabled: item.enabled,
      onExpansionChanged: (expanded) {
        if (!item.enabled) return;
        menuController.updateExpandedState(item.label, expanded);
      },
      content: item.content,
    );
  }
}

//*********************************************************************** */

/// Widget complet prêt à l'emploi qui gère :
/// - un header fixe (ItemController avec type = header)
/// - une liste scrollable de sections expansion
/// Vous pouvez déclarer plusieurs headers : ils seront empilés dans l'ordre
/// de déclaration (Map insertion order).
class MenuWidget extends StatefulWidget {
  final AppMenuController controller;
  final EdgeInsetsGeometry sectionsPadding;
  final ScrollController? scrollController;
  final bool showActionsBar;
  final double actionsBarHeight;
  final Color? actionsBarColor;
  final bool showShadowOverlay;
  final double shadowHeight;
  final List<Widget> Function(
    BuildContext context,
    bool allCollapsed,
    bool allExpanded,
    VoidCallback onCollapseAll,
    VoidCallback onExpandAll,
  )?
  customActionsBuilder;

  const MenuWidget({
    super.key,
    required this.controller,
    this.sectionsPadding = EdgeInsets.zero,
    this.scrollController,
    this.showActionsBar = true,
    this.actionsBarHeight = 40,
    this.actionsBarColor,
    this.showShadowOverlay = true,
    this.shadowHeight = 10,
    this.customActionsBuilder,
  });

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget>
    with MenuWidgetMixin<MenuWidget> {
  @override
  void initState() {
    super.initState();
    menuController = widget.controller;
    menuController.addListener(_refresh);
  }

  @override
  void dispose() {
    menuController.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headers = items.values
        .where((e) => e.isHeader && e.visible)
        .map(
          buildSection,
        ) // buildSection retourne directement content pour header
        .toList();
    final sections = items.values
        .where((e) => e.isSection && e.visible)
        .map(buildSection)
        .toList();

    // États globaux pour barre d'actions
    final visibleSections = items.values.where(
      (e) => e.isSection && e.visible && e.enabled,
    );
    final bool allCollapsed =
        visibleSections.isEmpty || visibleSections.every((e) => !e.expanded);
    final bool allExpanded =
        visibleSections.isNotEmpty && visibleSections.every((e) => e.expanded);

    Widget? actionsBar;
    if (widget.showActionsBar) {
      final actions = widget.customActionsBuilder != null
          ? widget.customActionsBuilder!(
              context,
              allCollapsed,
              allExpanded,
              collapseAll,
              expandAll,
            )
          : <Widget>[
              IconButton.filled(
                tooltip: 'Réduire tout',
                onPressed: allCollapsed ? null : collapseAll,
                icon: const Icon(Symbols.collapse_all, size: 18),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                tooltip: 'Tout développer',
                onPressed: allExpanded ? null : expandAll,
                icon: const Icon(Symbols.expand_all, size: 18),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
            ];
      actionsBar = Container(
        height: widget.actionsBarHeight,
        color: widget.actionsBarColor ?? Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: actions),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (headers.isNotEmpty)
          ...headers.map((w) => Material(elevation: 2, child: w)),
        if (actionsBar != null) Material(elevation: 2, child: actionsBar),
        Expanded(
          child: Stack(
            children: [
              ListView(
                controller: widget.scrollController,
                padding: widget.sectionsPadding,
                children: sections,
              ),
              if (widget.showShadowOverlay)
                IgnorePointer(
                  child: Container(
                    height: widget.shadowHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class MenuIds {}

class MiniIconButton extends StatefulWidget {
  final IconData icon;
  final IconData? hoverIcon;
  final double size;
  final VoidCallback onPressed;
  final Color? normalColor;
  final Color? hoverColor;
  final String? tooltip;

  const MiniIconButton({
    super.key,
    required this.icon,
    this.hoverIcon,
    required this.size,
    required this.onPressed,
    this.normalColor,
    this.hoverColor,
    this.tooltip,
  });

  @override
  State<MiniIconButton> createState() => _MiniIconButtonState();
}

class _MiniIconButtonState extends State<MiniIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      _isHovered && widget.hoverIcon != null ? widget.hoverIcon! : widget.icon,
      size: widget.size,
      color: _isHovered
          ? (widget.hoverColor ?? Colors.yellow)
          : (widget.normalColor ?? Colors.blueGrey.shade700),
    );

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: widget.tooltip != null
            ? Tooltip(
                message: widget.tooltip!,
                child: GestureDetector(
                  onTap: widget.onPressed,
                  child: iconWidget,
                ),
              )
            : GestureDetector(onTap: widget.onPressed, child: iconWidget),
      ),
    );
  }
}
