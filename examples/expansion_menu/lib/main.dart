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

  void _refresh() {
    if (!mounted) return;
    setState(() {
      // Simulate a refresh action
    });
  }

  @override
  void initState() {
    super.initState();
    menuController = AppMenuController({
      'header': ItemController(
        type: MenuType.header,
        expanded: true,
        label: 'header',
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
      'home': ItemController(
        type: MenuType.section,
        label: 'home',
        title: 'Accueil',
        icon: Icons.home,
        content: Container(
          color: Colors.amber,
          height: 100,
          child: Row(
            children: [
              IconButton(
                tooltip: "refresh",
                hoverColor: Colors.yellow,
                iconSize: 32,
                splashRadius: 28,
                onPressed: () async {
                  menuController.menuEntries['settings']!.expanded =
                      !menuController.menuEntries['settings']!.expanded;
                  _refresh();
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      ),
      'settings': ItemController(
        type: MenuType.section,
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
        type: MenuType.section,

        label: 'profile',
        title: 'Profil',
        icon: Icons.person,
        content: Container(
          height: 400,
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
