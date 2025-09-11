import 'package:flutter/material.dart';
import 'package:pkg_toolbox/toolbox.dart';

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

  @override
  void initState() {
    super.initState();
    menuController = AppMenuController({
      'home': ItemController(
        label: 'home',
        title: 'Accueil',
        icon: Icons.home,
        content: Container(
          color: Colors.amber,
          height: 100,
          child: Center(child: Text('Contenu de la section Accueil')),
        ),
      ),
      'settings': ItemController(
        label: 'settings',
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
      'profile': ItemController(
        label: 'profile',
        title: 'Profil',
        icon: Icons.person,
        content: Container(
          height: 200,
          color: Colors.greenAccent,
          child: Center(child: Text('Informations du profil utilisateur')),
        ),
      ),
    });
  }

  void collapseAll() {
    menuController.collapseAll();
    setState(() {});
  }

  void expandAll() {
    menuController.expandAll();
    setState(() {});
  }

  Widget buildSection(ItemController item) {
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
      content: item.content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expansion Menu Example'),
        actions: [
          IconButton(icon: const Icon(Icons.expand_more), onPressed: expandAll),
          IconButton(
            icon: const Icon(Icons.expand_less),
            onPressed: collapseAll,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            buildSection(menuController.menuEntries['home']!),
            buildSection(menuController.menuEntries['settings']!),
            buildSection(menuController.menuEntries['profile']!),
          ],
        ),
      ),
      body: const Center(child: Text('Contenu principal de l\'app')),
    );
  }
}
