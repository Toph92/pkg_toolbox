class MenuWidget extends StatefulWidget {
  final AppMenuController controller;

  const MenuWidget({super.key, required this.controller});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget>
    with MenuWidgetMixin<MenuWidget> {
  @override
  void initState() {
    super.initState();
    menuController = widget.controller;
  }

  double logoHeight = 80;
  double toolbarHeight = 40;

  @override
  Widget build(BuildContext context) {
    final visibleEnabled = items.values.where((e) => e.visible && e.enabled);
    final allCollapsed =
        visibleEnabled.isEmpty || visibleEnabled.every((e) => !e.expanded);
    final allExpanded =
        visibleEnabled.isNotEmpty && visibleEnabled.every((e) => e.expanded);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _MenuHeaderDelegate(
                allCollapsed: allCollapsed,
                allExpanded: allExpanded,
                onCollapseAll: collapseAll,
                onExpandAll: expandAll,
                isFlightDetailVisible: items['flightDetail']?.visible ?? false,
                onToggleFlightDetailVisibility: () {
                  final item = items['flightDetail']!;
                  setState(() {
                    item.visible = !item.visible;
                    if (!item.visible) {
                      item.expanded = false;
                      item.expansionController.collapse();
                    }
                  });
                },
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                buildSection(
                  items['dates']!,
                  // Ne pas muter l'ItemController dans build, fournir le contenu ici.
                  /* content: FlightCalendarWidget(
                    flightDates: widget.flightDates,
                    onDaySelected: widget.onDaySelected,
                  ), */
                ),
                buildSection(items['flights']!),
                buildSection(items['flightDetail']!),
                buildSection(items['tools']!),
                buildSection(items['help']!),
              ]),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(color: Colors.grey.shade300),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: logoHeight + toolbarHeight),
          child: IgnorePointer(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(
                      alpha: 0.6,
                    ), // Plus foncé en haut pour un effet d'ombre
                    Colors.transparent, // Transparent en bas
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.blue,
      child: const Center(
        child: Text(
          'Logo',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

class _MenuHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool allCollapsed;
  final bool allExpanded;
  final VoidCallback onCollapseAll;
  final VoidCallback onExpandAll;
  final bool isFlightDetailVisible;
  final VoidCallback onToggleFlightDetailVisibility;

  _MenuHeaderDelegate({
    required this.allCollapsed,
    required this.allExpanded,
    required this.onCollapseAll,
    required this.onExpandAll,
    required this.isFlightDetailVisible,
    required this.onToggleFlightDetailVisibility,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Column(
      children: [
        const _MenuHeader(),
        _MenuActionsBar(
          allCollapsed: allCollapsed,
          allExpanded: allExpanded,
          onCollapseAll: onCollapseAll,
          onExpandAll: onExpandAll,
          isFlightDetailVisible: isFlightDetailVisible,
          onToggleFlightDetailVisibility: onToggleFlightDetailVisibility,
        ),
      ],
    );
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 120;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class _MenuActionsBar extends StatelessWidget {
  final bool allCollapsed;
  final bool allExpanded;
  final VoidCallback onCollapseAll;
  final VoidCallback onExpandAll;
  final bool isFlightDetailVisible;
  final VoidCallback onToggleFlightDetailVisibility;

  const _MenuActionsBar({
    required this.allCollapsed,
    required this.allExpanded,
    required this.onCollapseAll,
    required this.onExpandAll,
    required this.isFlightDetailVisible,
    required this.onToggleFlightDetailVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 40,
      color: Colors.grey.shade400,
      child: Row(
        children: [
          IconButton.filled(
            tooltip: 'Réduire tout',
            onPressed: allCollapsed ? null : onCollapseAll,
            icon: const Icon(Symbols.collapse_all, size: 16),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          const SizedBox(width: 4),
          IconButton.filled(
            tooltip: 'Tout développer',
            onPressed: allExpanded ? null : onExpandAll,
            icon: const Icon(Symbols.expand_all, size: 16),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          const SizedBox(width: 4),
          IconButton.filled(
            tooltip: 'Toggle Détail vol visible',
            onPressed: onToggleFlightDetailVisibility,
            icon: Icon(
              isFlightDetailVisible
                  ? Symbols.visibility
                  : Symbols.visibility_off,
              size: 16,
            ),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ],
      ),
    );
  }
}

