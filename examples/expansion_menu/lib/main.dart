import 'package:flutter/material.dart';
import 'package:pkg_toolbox/toolbox.dart';

// Centralisation des labels pour éviter les fautes de frappe
class MainMenuIds extends MenuIds {
  static const header = 'header';
  static const home = 'home';
  static const settings = 'settings';
  static const profile = 'profile';
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expansion Menu Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final AppMenuController menuController;

  Widget _homeContent() {
    return Container(
      color: Colors.amber,
      height: 100,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Expand/Collapse settings',
            hoverColor: Colors.yellow,
            iconSize: 32,
            splashRadius: 28,
            onPressed: () {
              menuController.switchExpansion(MainMenuIds.settings);
            },
            icon: AnimatedBuilder(
              animation: menuController,
              builder: (_, __) {
                final entry = menuController.menuEntries[MainMenuIds.settings];
                final expanded = entry?.expanded == true;
                return Icon(
                  expanded ? Icons.arrow_downward : Icons.arrow_upward,
                );
              },
            ),
          ),
          IconButton(
            tooltip: 'Show/hide settings',
            hoverColor: Colors.yellow,
            iconSize: 32,
            splashRadius: 28,
            onPressed: () {
              menuController.switchVisibility(MainMenuIds.settings);
            },
            icon: AnimatedBuilder(
              animation: menuController,
              builder: (_, __) {
                final entry = menuController.menuEntries[MainMenuIds.settings];
                final visible = entry?.visible ?? false;
                return Icon(visible ? Icons.visibility_off : Icons.visibility);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Étape 1 : créer d'abord le controller (plus de référence avant affectation)
    menuController = AppMenuController();
    // Étape 2 : enregistrer les items qui peuvent désormais utiliser menuController
    menuController.registerAll([
      ItemController(
        type: MenuType.header,
        label: MainMenuIds.header,
        title: 'Header',
        content: Container(
          height: 200,
          color: Colors.blueGrey,
          child: const Center(
            child: Text(
              'Mon Header Fixe',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
      ItemController(
        type: MenuType.section,
        expanded: true,
        label: MainMenuIds.home,
        title: 'Accueil',
        icon: Icons.home,
        content: _homeContent(),
      ),
      ItemController(
        type: MenuType.section,
        label: MainMenuIds.settings,
        title: 'Paramètres',
        icon: Icons.settings,
        content: Column(
          children: [
            ListTile(title: const Text('Option 1'), onTap: () {}),
            ListTile(title: const Text('Option 2'), onTap: () {}),
            ListTile(title: const Text('Option 3'), onTap: () {}),
            ListTile(title: const Text('Option 4'), onTap: () {}),
          ],
        ),
      ),
      ItemController(
        type: MenuType.section,
        label: MainMenuIds.profile,
        title: 'Profil',
        icon: Icons.person,
        content: Container(
          height: 400,
          color: Colors.greenAccent,
          child: const Center(
            child: Text('Informations du profil utilisateur'),
          ),
        ),
      ),
    ]);
  }

  void collapseAll() {
    menuController.collapseAll();
    setState(() {});
  }

  void expandAll() {
    menuController.expandAll();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 1000;

    return Scaffold(
      appBar: AppBar(title: const Text('Expansion Menu Example')),
      drawer: isSmallScreen
          ? Drawer(child: MenuWidget(controller: menuController))
          : null,
      body: isSmallScreen
          ? const Center(child: Text('Contenu principal de l\'app'))
          : Row(
              children: [
                SizedBox(
                  width: 300,
                  child: Material(
                    elevation: 0,
                    child: MenuWidget(controller: menuController),
                  ),
                ),
                Container(
                  width: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.grey.shade700, Colors.grey.shade300],
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(child: Text('Contenu principal de l\'app')),
                ),
              ],
            ),
    );
  }
}
